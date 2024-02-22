import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:keyri_v3/fingerprint_event_response.dart';
import 'package:keyri_v3/fingerprint_request.dart';
import 'package:keyri_v3/session.dart';
import '../keyri_fingerprint_event.dart';
import '../login_object.dart';
import '../register_object.dart';
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
          'blockEmulatorDetection': (blockEmulatorDetection ?? true).toString()
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
          'blockEmulatorDetection': (blockEmulatorDetection ?? true).toString(),
          'payload': payload,
          'publicUserId': publicUserId
        }) ??
        false;
  }

  @override
  Future<String?> generateAssociationKey(String? publicUserId) async {
    return await methodChannel.invokeMethod<String>(
        'generateAssociationKey', {'publicUserId': publicUserId});
  }

  @override
  Future<String?> generateUserSignature(
      String? publicUserId, String data) async {
    return await methodChannel.invokeMethod<String>(
        'generateUserSignature', {'publicUserId': publicUserId, 'data': data});
  }

  @override
  Future<Map<String, String>> listAssociationKeys() async {
    final dynamic result =
        await methodChannel.invokeMethod('listAssociationKeys');
    final Map<String, String> resultMap = {};

    result.forEach((key, value) {
      if (key is String && value is String) {
        resultMap[key] = value;
      }
    });

    return Future.value(resultMap);
  }

  @override
  Future<Map<String, String>> listUniqueAccounts() async {
    final dynamic result =
        await methodChannel.invokeMethod('listUniqueAccounts');

    final Map<String, String> resultMap = {};

    result.forEach((key, value) {
      if (key is String && value is String) {
        resultMap[key] = value;
      }
    });

    return Future.value(resultMap);
  }

  @override
  Future<String?> getAssociationKey(String? publicUserId) async {
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
  Future<FingerprintEventResponse> sendEvent(
      String? publicUserId, EventType eventType, bool success) async {
    dynamic fingerprintEventResponseObject =
        await methodChannel.invokeMethod<dynamic>('sendEvent', {
      'publicUserId': publicUserId,
      'eventType': eventType.name,
      'metadata': json.encode(eventType.metadata),
      'success': success.toString()
    });

    return FingerprintEventResponse.fromJson(fingerprintEventResponseObject);
  }

  @override
  Future<FingerprintRequest> createFingerprint() async {
    dynamic fingerprintRequestObject =
        await methodChannel.invokeMethod<dynamic>('createFingerprint');

    return FingerprintRequest.fromJson(fingerprintRequestObject);
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
  Future<LoginObject> login(String? publicUserId) async {
    dynamic loginObject = await methodChannel
        .invokeMethod<dynamic>('login', {'publicUserId': publicUserId});

    return LoginObject.fromJson(loginObject);
  }

  @override
  Future<RegisterObject> register(String? publicUserId) async {
    dynamic registerObject = await methodChannel
        .invokeMethod<dynamic>('register', {'publicUserId': publicUserId});

    return RegisterObject.fromJson(registerObject);
  }

  @override
  Future<bool> initializeDefaultConfirmationScreen(String payload) async {
    return await methodChannel.invokeMethod<bool>(
            'initializeDefaultConfirmationScreen', {'payload': payload}) ??
        false;
  }

  @override
  Future<bool> confirmSession(String payload, bool trustNewBrowser) async {
    return await methodChannel.invokeMethod<bool>('confirmSession', {
          'payload': payload,
          'trustNewBrowser': trustNewBrowser.toString()
        }) ??
        false;
  }

  @override
  Future<bool> denySession(String payload) async {
    return await methodChannel
            .invokeMethod<bool>('denySession', {'payload': payload}) ??
        false;
  }
}
