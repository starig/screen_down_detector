import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Converts accelerometer readings into a confirmed screen-down event.
class ScreenDownController {
  ScreenDownController({required this.onScreenDown});

  static const double _screenDownThreshold = -8;
  static const double _resetThreshold = -5.0;
  static const double _maximumHorizontalAcceleration = 4.0;
  static const Duration _confirmationDuration = Duration(milliseconds: 150);

  final VoidCallback onScreenDown;

  Timer? _confirmationTimer;
  bool _isScreenDown = false;

  void handleAccelerometerEvent(AccelerometerEvent event) {
    final isFaceDownCandidate = event.z <= _screenDownThreshold &&
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
      onScreenDown();
    });
  }

  void dispose() {
    _confirmationTimer?.cancel();
    _confirmationTimer = null;
  }
}
