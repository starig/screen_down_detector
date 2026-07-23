import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'screen_down_controller.dart';

/// Called when the accelerometer event stream reports an error.
typedef ScreenDownErrorCallback = void Function(Object error);

/// A widget that reports when the device is placed with its screen facing down.
///
/// The accelerometer subscription is created when this widget is inserted into
/// the widget tree and is cancelled automatically when it is removed.
class ScreenDownDetector extends StatefulWidget {
  /// The confirmation duration used when no custom value is supplied.
  static const defaultConfirmationDuration = Duration(milliseconds: 150);

  /// Creates a screen-down detector around [child].
  const ScreenDownDetector({
    required this.onScreenDown,
    required this.child,
    this.onError,
    this.confirmationDuration = defaultConfirmationDuration,
    super.key,
  });

  /// Called once after the screen-down position has remained stable long enough
  /// to be confirmed.
  ///
  /// The detector must first observe the device leave the screen-down position
  /// before this callback can be called again.
  final VoidCallback onScreenDown;

  /// Called when the accelerometer event stream reports an error.
  ///
  /// If omitted, sensor errors are ignored.
  final ScreenDownErrorCallback? onError;

  /// How long the screen-down position must remain valid before confirmation.
  ///
  /// Defaults to [defaultConfirmationDuration]. A value of [Duration.zero]
  /// confirms the position on the next event-loop turn.
  final Duration confirmationDuration;

  /// The subtree below this detector.
  final Widget child;

  @override
  State<ScreenDownDetector> createState() => _ScreenDownDetectorState();
}

class _ScreenDownDetectorState extends State<ScreenDownDetector> {
  late final ScreenDownController _controller;
  StreamSubscription<AccelerometerEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    _controller = ScreenDownController(
      onScreenDown: () => widget.onScreenDown(),
      confirmationDuration: widget.confirmationDuration,
    );
    _subscription = accelerometerEventStream(
      samplingPeriod: SensorInterval.uiInterval,
    ).listen(
      _controller.handleAccelerometerEvent,
      onError: _handleSensorError,
      cancelOnError: true,
    );
  }

  void _handleSensorError(Object error) {
    widget.onError?.call(error);
  }

  @override
  void didUpdateWidget(covariant ScreenDownDetector oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.confirmationDuration != widget.confirmationDuration) {
      _controller.updateConfirmationDuration(widget.confirmationDuration);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
