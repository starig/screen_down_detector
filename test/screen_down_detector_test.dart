import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screen_down_detector/screen_down_detector.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const methodChannelName = 'dev.fluttercommunity.plus/sensors/method';
  const accelerometerChannelName =
      'dev.fluttercommunity.plus/sensors/accelerometer';
  const codec = StandardMethodCodec();

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  void emitAccelerometerEvent({
    required double x,
    required double y,
    required double z,
  }) {
    messenger.handlePlatformMessage(
      accelerometerChannelName,
      codec.encodeSuccessEnvelope(<double>[
        x,
        y,
        z,
        DateTime.now().microsecondsSinceEpoch.toDouble(),
      ]),
      (ByteData? _) {},
    );
  }

  void emitAccelerometerError() {
    messenger.handlePlatformMessage(
      accelerometerChannelName,
      codec.encodeErrorEnvelope(
        code: 'sensor_error',
        message: 'Accelerometer is unavailable',
      ),
      (ByteData? _) {},
    );
  }

  setUp(() {
    messenger.setMockMessageHandler(methodChannelName, (message) async {
      return codec.encodeSuccessEnvelope(null);
    });

    messenger.setMockMessageHandler(accelerometerChannelName, (message) async {
      final call = codec.decodeMethodCall(message);
      expect(call.method, anyOf('listen', 'cancel'));
      return codec.encodeSuccessEnvelope(null);
    });
  });

  tearDown(() {
    messenger.setMockMessageHandler(methodChannelName, null);
    messenger.setMockMessageHandler(accelerometerChannelName, null);
  });

  testWidgets('detects screen down and manages its own lifecycle', (
    tester,
  ) async {
    var callbackCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: ScreenDownDetector(
          onScreenDown: () => callbackCount++,
          confirmationDuration: const Duration(milliseconds: 500),
          child: const Text('child'),
        ),
      ),
    );

    expect(find.text('child'), findsOneWidget);

    emitAccelerometerEvent(x: 0, y: 0, z: -9);
    await tester.pump(const Duration(milliseconds: 499));

    expect(callbackCount, 0);

    await tester.pump(const Duration(milliseconds: 1));

    expect(callbackCount, 1);

    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    emitAccelerometerEvent(x: 0, y: 0, z: -9);
    await tester.pump(const Duration(milliseconds: 500));

    expect(callbackCount, 1);
  });

  testWidgets('reports sensor stream errors through onError', (tester) async {
    Object? reportedError;

    await tester.pumpWidget(
      MaterialApp(
        home: ScreenDownDetector(
          onScreenDown: () {},
          onError: (error) => reportedError = error,
          child: const SizedBox.shrink(),
        ),
      ),
    );

    emitAccelerometerError();
    await tester.pump();

    expect(
      reportedError,
      isA<PlatformException>().having(
        (error) => error.code,
        'code',
        'sensor_error',
      ),
    );

    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
  });
}
