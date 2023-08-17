import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:keyri/fingerprint_event_response.dart';
import 'package:keyri/session.dart';

import 'keyri_fingerprint_event.dart';
import 'keyri_platform_interface.dart';

/// An implementation of [KeyriPlatform] that uses method channels.
class MethodChannelKeyri extends KeyriPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('keyri');

  @override
  Future<bool> initialize(String appKey, String? publicApiKey,
      String? serviceEncryptionKey, bool? blockEmulatorDetection) async {
    return await methodChannel.invokeMethod<bool>('initialize', {
          'appKey': appKey,
          'publicApiKey': publicApiKey,
          'serviceEncryptionKey': serviceEncryptionKey,
          'blockEmulatorDetection': blockEmulatorDetection.toString()
        }) ??
        false;
  }

  @override
  Future<bool> easyKeyriAuth(
      String appKey,
      String? publicApiKey,
      String? serviceEncryptionKey,
      bool? blockEmulatorDetection,
      String payload,
      String? publicUserId) async {
    return await methodChannel.invokeMethod<bool>('easyKeyriAuth', {
          'appKey': appKey,
          'publicApiKey': publicApiKey,
          'serviceEncryptionKey': serviceEncryptionKey,
          'blockEmulatorDetection': blockEmulatorDetection.toString(),
          'payload': payload,
          'publicUserId': publicUserId
        }) ??
        false;
  }

  @override
  Future<String?> generateAssociationKey(String publicUserId) async {
    return await methodChannel.invokeMethod<String?>(
        'generateAssociationKey', {'publicUserId': publicUserId});
  }

  @override
  Future<String?> generateUserSignature(
      String? publicUserId, String data) async {
    return await methodChannel.invokeMethod<String?>(
        'generateUserSignature', {'publicUserId': publicUserId, 'data': data});
  }

  @override
  Future<Map<String, String>> listAssociationKeys() async {
    return await methodChannel
        .invokeMethod<Map<String, String>?>('listAssociationKeys')
        .then<Map<String, String>>((Map<String, String>? value) => value ?? {});
  }

  @override
  Future<Map<String, String>> listUniqueAccounts() async {
    return await methodChannel
        .invokeMethod<Map<String, String>?>('listUniqueAccounts')
        .then<Map<String, String>>((Map<String, String>? value) => value ?? {});
  }

  @override
  Future<String?> getAssociationKey(String publicUserId) async {
    return await methodChannel.invokeMethod<String?>(
        'getAssociationKey', {'publicUserId': publicUserId});
  }

  @override
  Future<bool> removeAssociationKey(String publicUserId) async {
    return await methodChannel.invokeMethod<bool>(
            'removeAssociationKey', {'publicUserId': publicUserId}) ??
        false;
  }

  @override
  Future<FingerprintEventResponse?> sendEvent(
      String publicUserId, EventType eventType, bool success) async {
    return await methodChannel.invokeMethod<FingerprintEventResponse?>(
        'sendEvent', {
      'publicUserId': publicUserId,
      'eventType': eventType.name,
      'success': success
    });
  }

  @override
  Future<Session> initiateQrSession(
      String sessionId, String? publicUserId) async {
    dynamic sessionObject = await methodChannel.invokeMethod<dynamic>(
        'initiateQrSession',
        {'sessionId': sessionId, 'publicUserId': publicUserId});

    return Session.fromJson(sessionObject);
  }

  @override
  Future<bool> initializeDefaultScreen(String sessionId, String payload) async {
    return await methodChannel.invokeMethod<bool>('initializeDefaultScreen',
            {'sessionId': sessionId, 'payload': payload}) ??
        false;
  }

  @override
  Future<bool> confirmSession(String sessionId, String payload) async {
    return await methodChannel.invokeMethod<bool>(
            'confirmSession', {'sessionId': sessionId, 'payload': payload}) ??
        false;
  }

  @override
  Future<bool> denySession(String sessionId, String payload) async {
    return await methodChannel.invokeMethod<bool>(
            'denySession', {'sessionId': sessionId, 'payload': payload}) ??
        false;
  }
}
