import 'package:keyri_v3/fingerprint_event_response.dart';
import 'package:keyri_v3/session.dart';

import 'keyri_fingerprint_event.dart';
import 'keyri_platform_interface.dart';

class Keyri {
  String appKey = '';
  String? publicApiKey;
  String? serviceEncryptionKey;
  bool blockEmulatorDetection = true;

  Keyri(this.appKey, this.publicApiKey, this.serviceEncryptionKey,
      this.blockEmulatorDetection) {
    if (appKey.isEmpty) {
      throw Exception('You need to specify appKey');
    }

    KeyriPlatform.instance
        .initialize(
            appKey, publicApiKey, serviceEncryptionKey, blockEmulatorDetection)
        .then((isInitialized) => {
              if (!isInitialized)
                {throw Exception('You need to specify appKey')}
            });
  }

  Future<bool?> easyKeyriAuth(
      String appKey,
      String? publicApiKey,
      String? serviceEncryptionKey,
      bool? blockEmulatorDetection,
      String payload,
      String? publicUserId) {
    return KeyriPlatform.instance.easyKeyriAuth(appKey, publicApiKey,
        serviceEncryptionKey, blockEmulatorDetection, payload, publicUserId);
  }

  Future<String?> generateAssociationKey(String? publicUserId) {
    return KeyriPlatform.instance.generateAssociationKey(publicUserId);
  }

  Future<String?> generateUserSignature(String? publicUserId, String data) {
    return KeyriPlatform.instance.generateUserSignature(publicUserId, data);
  }

  Future<Map<String, String>> listAssociationKeys() {
    return KeyriPlatform.instance.listAssociationKeys();
  }

  Future<Map<String, String>> listUniqueAccounts() {
    return KeyriPlatform.instance.listUniqueAccounts();
  }

  Future<String?> getAssociationKey(String? publicUserId) {
    return KeyriPlatform.instance.getAssociationKey(publicUserId);
  }

  Future<bool> removeAssociationKey(String publicUserId) {
    return KeyriPlatform.instance.removeAssociationKey(publicUserId);
  }

  Future<FingerprintEventResponse> sendEvent(
      String? publicUserId, EventType eventType, bool success) {
    return KeyriPlatform.instance.sendEvent(publicUserId, eventType, success);
  }

  Future<Session?> initiateQrSession(String sessionId, String? publicUserId) {
    return KeyriPlatform.instance.initiateQrSession(sessionId, publicUserId);
  }

  Future<bool> initializeDefaultConfirmationScreen(String payload) {
    return KeyriPlatform.instance.initializeDefaultConfirmationScreen(payload);
  }

  Future<bool> processLink(String link, String payload, String? publicUserId) {
    return KeyriPlatform.instance.processLink(link, payload, publicUserId);
  }

  Future<bool> confirmSession(String payload, bool trustNewBrowser) {
    return KeyriPlatform.instance.confirmSession(payload, trustNewBrowser);
  }

  Future<bool> denySession(String payload) {
    return KeyriPlatform.instance.denySession(payload);
  }
}
