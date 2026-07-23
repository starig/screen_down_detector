import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'screen_down_controller.dart';

/// A widget that reports when the device is placed with its screen facing down.
///
/// The accelerometer subscription is created when this widget is inserted into
/// the widget tree and is cancelled automatically when it is removed.
class ScreenDownDetector extends StatefulWidget {
  /// Creates a screen-down detector around [child].
  const ScreenDownDetector({
    required this.onScreenDown,
    required this.child,
    super.key,
  });

  /// Called once after the screen-down position has remained stable long enough
  /// to be confirmed.
  ///
  /// The detector must first observe the device leave the screen-down position
  /// before this callback can be called again.
  final VoidCallback onScreenDown;

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
    // handle the error
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
