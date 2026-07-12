# periscope_flutter

Flutter bridge for `PeriscopeKit` (iOS) and `PeriscopeAndroid` (Android).

## Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  periscope_flutter:
    git:
      url: https://github.com/ryanneilstroud/periscope-flutter.git
```

Then run:

```bash
flutter pub get
```

## Usage

```dart
import 'package:periscope_flutter/periscope_flutter.dart';

await Periscope.capture(
  receiver: const PeriscopeReceiver(
    host: '192.168.1.100',
    port: 61337,
  ),
);
```

Stop monitoring:

```dart
await Periscope.stop();
```

Send a test request:

```dart
final statusCode = await Periscope.sendTestRequest();
```

## Platform support

- iOS: supported
- Android: supported
