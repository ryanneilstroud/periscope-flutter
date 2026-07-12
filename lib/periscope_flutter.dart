import 'package:flutter/services.dart';

class PeriscopeReceiver {
  const PeriscopeReceiver({this.host, this.port});

  final String? host;
  final int? port;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      if (host != null) 'host': host,
      if (port != null) 'port': port,
    };
  }
}

class PeriscopeCaptureOptions {
  const PeriscopeCaptureOptions({this.receiver, this.host, this.port});

  final PeriscopeReceiver? receiver;
  final String? host;
  final int? port;

  Map<String, Object?> toMap() {
    if (receiver != null) {
      return <String, Object?>{'receiver': receiver!.toMap()};
    }

    return <String, Object?>{
      if (host != null) 'host': host,
      if (port != null) 'port': port,
    };
  }
}

class Periscope {
  static const MethodChannel _channel = MethodChannel('periscope_flutter');

  static Future<void> capture({
    PeriscopeReceiver? receiver,
    String? host,
    int? port,
  }) {
    final options = PeriscopeCaptureOptions(
      receiver: receiver,
      host: host,
      port: port,
    );
    return _channel.invokeMethod<void>('capture', options.toMap());
  }

  static Future<void> stop() {
    return _channel.invokeMethod<void>('stop');
  }

  static Future<int> sendTestRequest([String? url]) async {
    final statusCode =
        await _channel.invokeMethod<int>('sendTestRequest', url);
    if (statusCode == null) {
      throw PlatformException(
        code: 'null_status_code',
        message: 'sendTestRequest returned null.',
      );
    }
    return statusCode;
  }
}
