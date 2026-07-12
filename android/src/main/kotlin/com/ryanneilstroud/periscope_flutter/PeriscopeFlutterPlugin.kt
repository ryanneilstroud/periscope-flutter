package com.ryanneilstroud.periscope_flutter

import android.os.Handler
import android.os.Looper
import com.ryanneilstroud.periscopeandroid.Periscope
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import okhttp3.HttpUrl.Companion.toHttpUrlOrNull
import okhttp3.OkHttpClient
import okhttp3.Request

/** PeriscopeFlutterPlugin */
class PeriscopeFlutterPlugin : FlutterPlugin, MethodCallHandler {
  private lateinit var channel: MethodChannel
  private val mainHandler = Handler(Looper.getMainLooper())

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "periscope_flutter")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "capture" -> capture(call, result)
      "stop" -> stop(result)
      "sendTestRequest" -> sendTestRequest(call, result)
      else -> result.notImplemented()
    }
  }

  private fun capture(call: MethodCall, result: Result) {
    val options = call.arguments as? Map<*, *>
    val receiver = (options?.get("receiver") as? Map<*, *>) ?: options
    val requestedPort = (receiver?.get("port") as? Number)?.toInt()
    val port = requestedPort ?: 61337

    if (port !in 1..65_535) {
      result.error("invalid_port", "Expected port in range 1...65535.", null)
      return
    }

    val host = (receiver?.get("host") as? String)?.trim()?.takeIf { it.isNotEmpty() }
    val periscopeReceiver = if (host == null) {
      Periscope.Receiver.simulator(port)
    } else {
      Periscope.Receiver.device(host, port)
    }

    Periscope.capture(periscopeReceiver)
    result.success(null)
  }

  private fun stop(result: Result) {
    Periscope.stop()
    result.success(null)
  }

  private fun sendTestRequest(call: MethodCall, result: Result) {
    val resolvedURLString = (call.arguments as? String)?.trim().takeUnless { it.isNullOrEmpty() }
      ?: "https://jsonplaceholder.typicode.com/todos/1"
    val url = resolvedURLString.toHttpUrlOrNull()

    if (url == null) {
      result.error("invalid_url", "sendTestRequest expected a valid URL string.", null)
      return
    }

    Thread {
      try {
        val client = OkHttpClient.Builder()
          .addInterceptor(Periscope.default.interceptor())
          .build()
        val request = Request.Builder()
          .url(url)
          .build()

        client.newCall(request).execute().use { response ->
          mainHandler.post { result.success(response.code) }
        }
      } catch (error: Exception) {
        mainHandler.post { result.error("request_failed", error.message, error.toString()) }
      }
    }.start()
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
