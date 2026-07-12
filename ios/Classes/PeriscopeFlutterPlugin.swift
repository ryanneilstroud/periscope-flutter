import Flutter
import Foundation
import PeriscopeKit

public class SwiftPeriscopeFlutterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "periscope_flutter", binaryMessenger: registrar.messenger())
    let instance = SwiftPeriscopeFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "capture":
      capture(call: call, result: result)
    case "stop":
      stop(result: result)
    case "sendTestRequest":
      sendTestRequest(call: call, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func capture(call: FlutterMethodCall, result: @escaping FlutterResult) {
    let options = call.arguments as? [String: Any]
    let receiver = options?["receiver"] as? [String: Any] ?? options
    let requestedPort = receiver?["port"] as? NSNumber
    let portValue = requestedPort?.intValue ?? 61337

    guard (1...65_535).contains(portValue) else {
      result(FlutterError(code: "invalid_port", message: "Expected port in range 1...65535.", details: nil))
      return
    }

    let host = (receiver?["host"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
    let targetReceiver: Periscope.Receiver
    if let host, !host.isEmpty {
      targetReceiver = .device(host: host, port: portValue)
    } else {
      targetReceiver = .simulator(port: portValue)
    }

    Periscope.capture(for: targetReceiver)
    result(nil)
  }

  private func stop(result: @escaping FlutterResult) {
    Periscope.stop()
    result(nil)
  }

  private func sendTestRequest(call: FlutterMethodCall, result: @escaping FlutterResult) {
    let urlString = (call.arguments as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
    let resolvedURLString = (urlString?.isEmpty == false) ? urlString! : "https://jsonplaceholder.typicode.com/todos/1"

    guard let url = URL(string: resolvedURLString) else {
      result(FlutterError(code: "invalid_url", message: "sendTestRequest expected a valid URL string.", details: nil))
      return
    }

    let configuration = URLSessionConfiguration.default
    Periscope.inject(into: configuration)
    let session = URLSession(configuration: configuration)

    session.dataTask(with: url) { _, response, error in
      defer { session.finishTasksAndInvalidate() }

      if let error {
        DispatchQueue.main.async {
          result(FlutterError(code: "request_failed", message: error.localizedDescription, details: nil))
        }
        return
      }

      let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
      DispatchQueue.main.async {
        result(statusCode)
      }
    }.resume()
  }
}
