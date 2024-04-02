import 'package:keyri_v3/fingerprint_request.dart';
import 'package:keyri_v3/session.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../fingerprint_event_response.dart';
import '../keyri_detections_config.dart';
import '../keyri_fingerprint_event.dart';
import '../login_object.dart';
import '../register_object.dart';
import 'keyri_method_channel.dart';

abstract class KeyriPlatform extends PlatformInterface {
  /// Constructs a KeyriPlatform.
  KeyriPlatform() : super(token: _token);

  static final Object _token = Object();

  static KeyriPlatform _instance = MethodChannelKeyri();

  /// The default instance of [KeyriPlatform] to use.
  ///
  /// Defaults to [MethodChannelKeyri].
  static KeyriPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [KeyriPlatform] when
  /// they register themselves.
  static set instance(KeyriPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<bool> initialize(String appKey, String? publicApiKey,
      String? serviceEncryptionKey, KeyriDetectionsConfig detectionsConfig) {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  Future<bool> easyKeyriAuth(
      String appKey,
      String? publicApiKey,
      String? serviceEncryptionKey,
      KeyriDetectionsConfig detectionsConfig,
      String payload,
      String? publicUserId) {
    throw UnimplementedError('easyKeyriAuth() has not been implemented.');
  }

  Future<String?> generateAssociationKey(String? publicUserId) {
    throw UnimplementedError(
        'generateAssociationKey() has not been implemented.');
  }

  Future<String?> generateUserSignature(String? publicUserId, String data) {
    throw UnimplementedError(
        'generateUserSignature() has not been implemented.');
  }

  Future<Map<String, String>> listAssociationKeys() {
    throw UnimplementedError('listAssociationKeys() has not been implemented.');
  }

  Future<Map<String, String>> listUniqueAccounts() {
    throw UnimplementedError('listUniqueAccounts() has not been implemented.');
  }

  Future<String?> getAssociationKey(String? publicUserId) {
    throw UnimplementedError('getAssociationKey() has not been implemented.');
  }

  Future<bool> removeAssociationKey(String publicUserId) {
    throw UnimplementedError(
        'removeAssociationKey() has not been implemented.');
  }

  Future<FingerprintEventResponse> sendEvent(
      String? publicUserId, EventType eventType, bool success) {
    throw UnimplementedError('sendEvent() has not been implemented.');
  }

  Future<FingerprintRequest> createFingerprint() {
    throw UnimplementedError('createFingerprint() has not been implemented.');
  }

  Future<Session> initiateQrSession(String sessionId, String? publicUserId) {
    throw UnimplementedError('initiateQrSession() has not been implemented.');
  }

  Future<LoginObject> login(String? publicUserId) {
    throw UnimplementedError('login() has not been implemented.');
  }

  Future<RegisterObject> register(String? publicUserId) {
    throw UnimplementedError('register() has not been implemented.');
  }

  Future<int> getCorrectedTimestampSeconds() {
    throw UnimplementedError('getCorrectedTimestampSeconds() has not been implemented.');
  }

  Future<bool> initializeDefaultConfirmationScreen(String payload) {
    throw UnimplementedError(
        'initializeDefaultConfirmationScreen() has not been implemented.');
  }

  Future<bool> processLink(String link, String payload, String? publicUserId) {
    throw UnimplementedError('processLink() has not been implemented.');
  }

  Future<bool> confirmSession(String payload, bool trustNewBrowser) {
    throw UnimplementedError('confirmSession() has not been implemented.');
  }

  Future<bool> denySession(String payload) {
    throw UnimplementedError('denySession() has not been implemented.');
  }
}
