import 'package:flutter/services.dart';

class ImeHelper {
  const ImeHelper._();

  static const MethodChannel _channel = MethodChannel('com.zzy.studyloop/ime');

  static Future<void> showSoftInput() async {
    try {
      await SystemChannels.textInput.invokeMethod('TextInput.show');
    } catch (_) {}
    try {
      await _channel.invokeMethod('showSoftInput');
    } catch (_) {}
  }

  static Future<void> hideSoftInput() async {
    try {
      await SystemChannels.textInput.invokeMethod('TextInput.hide');
    } catch (_) {}
    try {
      await _channel.invokeMethod('hideSoftInput');
    } catch (_) {}
  }
}
