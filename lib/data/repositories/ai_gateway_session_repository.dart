import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

abstract class AiGatewaySessionProvider {
  Future<String?> acquire(String gatewayBaseUrl);
}

class PlatformAiGatewaySessionProvider implements AiGatewaySessionProvider {
  PlatformAiGatewaySessionProvider({
    HttpClient? httpClient,
    MethodChannel? integrityChannel,
  }) : _client = httpClient ?? HttpClient(),
       _integrityChannel =
           integrityChannel ??
           const MethodChannel('com.zzy.studyloop/integrity');

  static const _installationIdKey = 'studyloop.aiGatewayInstallationId';

  final HttpClient _client;
  final MethodChannel _integrityChannel;

  @override
  Future<String?> acquire(String gatewayBaseUrl) async {
    final baseUri = Uri.tryParse(gatewayBaseUrl.trim());
    if (baseUri == null || !baseUri.hasScheme || !baseUri.hasAuthority) {
      return null;
    }

    try {
      final preferences = await SharedPreferences.getInstance();
      final installationId =
          preferences.getString(_installationIdKey) ?? const Uuid().v4();
      await preferences.setString(_installationIdKey, installationId);

      final requestHash = const Uuid().v4();
      final integrityToken = await _integrityChannel.invokeMethod<String>(
        'requestIntegrityToken',
        {'requestHash': requestHash},
      );
      if (integrityToken == null || integrityToken.isEmpty) return null;

      final request = await _client
          .postUrl(baseUri.resolve('/v1/session'))
          .timeout(const Duration(seconds: 5));
      request.headers.contentType = ContentType.json;
      request.write(
        jsonEncode({
          'installationId': installationId,
          'requestHash': requestHash,
          'integrityToken': integrityToken,
        }),
      );
      final response = await request.close().timeout(
        const Duration(seconds: 5),
      );
      if (response.statusCode != HttpStatus.ok) return null;

      final body = await response.transform(utf8.decoder).join();
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) return null;
      final token = decoded['accessToken'];
      return token is String && token.isNotEmpty ? token : null;
    } on Object {
      return null;
    }
  }
}
