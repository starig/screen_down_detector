import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screen_down_detector/src/screen_down_controller.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() {
  AccelerometerEvent event({
    required double x,
    required double y,
    required double z,
  }) {
    return AccelerometerEvent(x, y, z, DateTime(2026));
  }

  group('ScreenDownController', () {
    test('calls back only after the position is confirmed', () {
      fakeAsync((async) {
        var callbackCount = 0;
        final controller = ScreenDownController(
          onScreenDown: () => callbackCount++,
        );

        controller.handleAccelerometerEvent(event(x: 0, y: 0, z: -8));
        async.elapse(const Duration(milliseconds: 149));

        expect(callbackCount, 0);

        async.elapse(const Duration(milliseconds: 1));

        expect(callbackCount, 1);
      });
    });

    test(
      'cancels confirmation when the device moves away from screen down',
      () {
        fakeAsync((async) {
          var callbackCount = 0;
          final controller = ScreenDownController(
            onScreenDown: () => callbackCount++,
          );

          controller.handleAccelerometerEvent(event(x: 0, y: 0, z: -9));
          async.elapse(const Duration(milliseconds: 100));
          controller.handleAccelerometerEvent(event(x: 0, y: 0, z: -7));
          async.elapse(const Duration(milliseconds: 150));

          expect(callbackCount, 0);
        });
      },
    );

    test('ignores events with excessive horizontal acceleration', () {
      fakeAsync((async) {
        var callbackCount = 0;
        final controller = ScreenDownController(
          onScreenDown: () => callbackCount++,
        );

        controller.handleAccelerometerEvent(event(x: 4.1, y: 0, z: -9));
        controller.handleAccelerometerEvent(event(x: 0, y: -4.1, z: -9));
        async.elapse(const Duration(milliseconds: 150));

        expect(callbackCount, 0);
      });
    });

    test('does not call back again until the detector is reset', () {
      fakeAsync((async) {
        var callbackCount = 0;
        final controller = ScreenDownController(
          onScreenDown: () => callbackCount++,
        );

        controller.handleAccelerometerEvent(event(x: 0, y: 0, z: -9));
        async.elapse(const Duration(milliseconds: 150));
        controller.handleAccelerometerEvent(event(x: 0, y: 0, z: -9));
        async.elapse(const Duration(milliseconds: 150));
        controller.handleAccelerometerEvent(event(x: 0, y: 0, z: -6));
        controller.handleAccelerometerEvent(event(x: 0, y: 0, z: -9));
        async.elapse(const Duration(milliseconds: 150));

        expect(callbackCount, 1);

        controller.handleAccelerometerEvent(event(x: 0, y: 0, z: -5));
        controller.handleAccelerometerEvent(event(x: 0, y: 0, z: -9));
        async.elapse(const Duration(milliseconds: 150));

        expect(callbackCount, 2);
      });
    });

    test('cancels a pending callback when disposed', () {
      fakeAsync((async) {
        var callbackCount = 0;
        final controller = ScreenDownController(
          onScreenDown: () => callbackCount++,
        );

        controller.handleAccelerometerEvent(event(x: 0, y: 0, z: -9));
        async.elapse(const Duration(milliseconds: 100));
        controller.dispose();
        async.elapse(const Duration(milliseconds: 150));

        expect(callbackCount, 0);
      });
    });
  });
}
