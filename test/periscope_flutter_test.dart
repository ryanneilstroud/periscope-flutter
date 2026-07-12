import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:periscope_flutter/periscope_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('periscope_flutter');

  final List<MethodCall> log = <MethodCall>[];

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      log.add(methodCall);
      if (methodCall.method == 'sendTestRequest') return 200;
      return null;
    });
    log.clear();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('capture sends receiver map', () async {
    await Periscope.capture(
      receiver: const PeriscopeReceiver(host: '192.168.1.25', port: 61337),
    );

    expect(log, hasLength(1));
    expect(log.first.method, 'capture');
    expect(log.first.arguments, <String, Object?>{
      'receiver': <String, Object?>{
        'host': '192.168.1.25',
        'port': 61337,
      },
    });
  });

  test('stop invokes stop method', () async {
    await Periscope.stop();

    expect(log, hasLength(1));
    expect(log.first.method, 'stop');
  });

  test('sendTestRequest returns status code', () async {
    final statusCode = await Periscope.sendTestRequest();

    expect(log, hasLength(1));
    expect(log.first.method, 'sendTestRequest');
    expect(statusCode, 200);
  });
}
