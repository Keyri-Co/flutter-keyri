import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:keyri/session.dart';

import 'keyri_platform_interface.dart';
import 'dart:convert';

/// An implementation of [KeyriPlatform] that uses method channels.
class MethodChannelKeyri extends KeyriPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('keyri');

  @override
  Future<bool> easyKeyriAuth(String appKey, String payload, String? publicUserId) async {
    return await methodChannel.invokeMethod<bool>('easyKeyriAuth', {
      'appKey': appKey,
      'payload': payload,
      'publicUserId': publicUserId
    }).then<bool>((bool? value) => value ?? false);
  }

  @override
  Future<String?> generateAssociationKey(String publicUserId) async {
    return await methodChannel.invokeMethod<String?>(
        'generateAssociationKey', {'publicUserId': publicUserId});
  }

  @override
  Future<String?> getUserSignature(
      String? publicUserId, String customSignedData) async {
    return await methodChannel.invokeMethod<String?>('getUserSignature',
        {'publicUserId': publicUserId, 'customSignedData': customSignedData});
  }

  @override
  Future<List<String>> listAssociationKey() async {
    return await methodChannel
        .invokeMethod<List<String>?>('listAssociationKey')
        .then<List<String>>((List<String>? value) => value ?? []);
  }

  @override
  Future<String?> getAssociationKey(String publicUserId) async {
    return await methodChannel.invokeMethod<String?>(
        'getAssociationKey', {'publicUserId': publicUserId});
  }

  @override
  Future<Session?> initiateQrSession(
      String appKey, String sessionId, String? publicUserId) async {
    dynamic sessionObject = await methodChannel.invokeMethod<dynamic>(
        'initiateQrSession', {
      'appKey': appKey,
      'sessionId': sessionId,
      'publicUserId': publicUserId
    });

    return Session.fromJson(jsonDecode(sessionObject));
  }

  @override
  Future<bool> initializeDefaultScreen(String sessionId, String payload) async {
    return await methodChannel.invokeMethod<bool>('initializeDefaultScreen', {
      'sessionId': sessionId,
      'payload': payload
    }).then<bool>((bool? value) => value ?? false);
  }

  @override
  Future<bool> confirmSession(String sessionId, String payload) async {
    return await methodChannel.invokeMethod<bool>('confirmSession', {
      'sessionId': sessionId,
      'payload': payload
    }).then<bool>((bool? value) => value ?? false);
  }

  @override
  Future<bool> denySession(String sessionId, String payload) async {
    return await methodChannel.invokeMethod<bool>('denySession', {
      'sessionId': sessionId,
      'payload': payload
    }).then<bool>((bool? value) => value ?? false);
  }
}
