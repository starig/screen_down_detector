# screen_down_detector

A Flutter widget that detects when a device is placed with its screen facing
down.

The detector manages the accelerometer subscription and its lifecycle
automatically. It invokes the callback once per screen-down gesture and waits
for the device to leave that position before it can invoke the callback again.

## Platform support

- Android
- iOS

Use a physical device when testing. Simulators might not provide accelerometer
events.

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  screen_down_detector: ^0.0.1
```

Then run:

```sh
flutter pub get
```

### iOS setup

Add `NSMotionUsageDescription` inside the `<dict>` element in your
`ios/Runner/Info.plist`:

```xml
<key>NSMotionUsageDescription</key>
<string>This app uses motion sensors to detect when the device is placed screen-down.</string>
```

The text shown above is an example. You can customize it, but it should clearly
explain why your application needs access to motion sensor data.

## Usage

Import the package and wrap the subtree that should listen for screen-down
events:

```dart
import 'package:flutter/material.dart';
import 'package:screen_down_detector/screen_down_detector.dart';

class SensitiveContent extends StatelessWidget {
  const SensitiveContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenDownDetector(
      onScreenDown: () {
        // Hide sensitive content, lock the screen, or trigger another action.
      },
      onError: (error) {
        // Report or otherwise handle a sensor error.
      },
      confirmationDuration: const Duration(milliseconds: 300),
      child: const Scaffold(
        body: Center(
          child: Text('Sensitive content'),
        ),
      ),
    );
  }
}
```

`ScreenDownDetector` starts listening in `initState` and stops listening in
`dispose`; no manual lifecycle calls are required.

Both `onError` and `confirmationDuration` are optional. The default confirmation
duration is 150 milliseconds.

## How detection works

The package uses `sensors_plus` to receive accelerometer events.

A screen-down event is confirmed when:

- the accelerometer's `z` value is at most `-8 m/s²`;
- horizontal acceleration remains within `±4 m/s²`;
- the position remains valid for 150 milliseconds.

The callback is invoked only once until the detector observes a reset position.

## Example

See the complete runnable application in the [`example`](example) directory.

## Issues

Please report issues on the
[GitHub issue tracker](https://github.com/starig/screen_down_detector/issues).
