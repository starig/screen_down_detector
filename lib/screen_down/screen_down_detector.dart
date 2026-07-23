import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:sensors_plus/sensors_plus.dart';

class ScreenDownDetector extends StatefulWidget {
  const ScreenDownDetector({required this.onScreenDown, required this.child, super.key});

  final VoidCallback onScreenDown;
  final Widget child;

  @override
  State<ScreenDownDetector> createState() => _ScreenDownDetectorState();
}

class _ScreenDownDetectorState extends State<ScreenDownDetector> {
  static const double _screenDownThreshold = -8;
  static const double _resetThreshold = -5.0;
  static const double _maximumHorizontalAcceleration = 4.0;
  static const Duration _confirmationDuration = Duration(milliseconds: 150);

  StreamSubscription<AccelerometerEvent>? _subscription;
  Timer? _confirmationTimer;
  bool _isScreenDown = false;

  @override
  void initState() {
    super.initState();
    _subscription = accelerometerEventStream(
      samplingPeriod: SensorInterval.uiInterval,
    ).listen(_handleAccelerometerEvent, onError: _handleSensorError, cancelOnError: true);
  }

  void _handleAccelerometerEvent(AccelerometerEvent event) {
    final isFaceDownCandidate =
        event.z <= _screenDownThreshold &&
        event.x.abs() <= _maximumHorizontalAcceleration &&
        event.y.abs() <= _maximumHorizontalAcceleration;

    if (isFaceDownCandidate) {
      _scheduleScreenDownCallback();
      return;
    }

    _confirmationTimer?.cancel();
    _confirmationTimer = null;

    if (event.z >= _resetThreshold) {
      _isScreenDown = false;
    }
  }

  void _scheduleScreenDownCallback() {
    if (_isScreenDown || _confirmationTimer != null) {
      return;
    }

    _confirmationTimer = Timer(_confirmationDuration, () {
      _confirmationTimer = null;
      _isScreenDown = true;

      widget.onScreenDown();
    });
  }

  void _handleSensorError(Object error) {
    // handle the error
  }

  @override
  void dispose() {
    _confirmationTimer?.cancel();
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
