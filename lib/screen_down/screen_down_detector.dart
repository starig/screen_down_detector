import 'dart:async';

import 'package:device_position/screen_down/screen_down_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:sensors_plus/sensors_plus.dart';

class ScreenDownDetector extends StatefulWidget {
  const ScreenDownDetector({
    required this.onScreenDown,
    required this.child,
    super.key,
  });

  final VoidCallback onScreenDown;
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
    _subscription =
        accelerometerEventStream(
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
