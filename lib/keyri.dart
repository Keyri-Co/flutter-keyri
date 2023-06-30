import 'package:keyri/session.dart';

import 'keyri_fingerprint_event.dart';
import 'keyri_platform_interface.dart';

class Keyri {
  Future<bool?> initialize(
      String appKey, String? publicApiKey, String? serviceEncryptionKey, bool? blockEmulatorDetection) {
    return KeyriPlatform.instance
        .initialize(appKey, publicApiKey, serviceEncryptionKey, blockEmulatorDetection);
  }

  Future<bool?> easyKeyriAuth(String appKey, String? publicApiKey, String? serviceEncryptionKey,
      String payload, String? publicUserId) {
    return KeyriPlatform.instance
        .easyKeyriAuth(appKey, publicApiKey, serviceEncryptionKey, payload, publicUserId);
  }

  Future<String?> generateAssociationKey(String publicUserId) {
    return KeyriPlatform.instance.generateAssociationKey(publicUserId);
  }

  Future<String?> getUserSignature(
      String? publicUserId, String customSignedData) {
    return KeyriPlatform.instance
        .getUserSignature(publicUserId, customSignedData);
  }

  Future<Map<String, String>> listAssociationKey() {
    return KeyriPlatform.instance.listAssociationKey();
  }

  Future<Map<String, String>> listUniqueAccounts() {
    return KeyriPlatform.instance.listUniqueAccounts();
  }

  Future<String?> getAssociationKey(String publicUserId) {
    return KeyriPlatform.instance.getAssociationKey(publicUserId);
  }

  Future<bool> removeAssociationKey(String publicUserId) {
    return KeyriPlatform.instance.removeAssociationKey(publicUserId);
  }

  Future<bool> sendEvent(String publicUserId,
      EventType eventType, bool success) {
    return KeyriPlatform.instance
        .sendEvent(publicUserId, eventType, eventResult);
  }

  Future<Session?> initiateQrSession(
      String appKey, String sessionId, String? publicUserId) {
    return KeyriPlatform.instance
        .initiateQrSession(appKey, sessionId, publicUserId);
  }

  Future<bool> initializeDefaultScreen(String sessionId, String payload) {
    return KeyriPlatform.instance.initializeDefaultScreen(sessionId, payload);
  }

  Future<bool> processLink(
      String link, String appKey, String payload, String publicUserId) {
    return KeyriPlatform.instance
        .processLink(link, appKey, payload, publicUserId);
  }

  Future<bool> confirmSession(String sessionId, String payload) {
    return KeyriPlatform.instance.confirmSession(sessionId, payload);
  }

  Future<bool> denySession(String sessionId, String payload) {
    return KeyriPlatform.instance.denySession(sessionId, payload);
  }
}
