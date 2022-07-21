import 'package:keyri/session.dart';

import 'keyri_platform_interface.dart';

class Keyri {

  /// To Use this method, make sure your host Activity extended from FlutterFragmentActivity
  Future<bool> easyKeyriAuth(
      String appKey, String payload, String? publicUserId) {
    return KeyriPlatform.instance.easyKeyriAuth(appKey, payload, publicUserId);
  }

  Future<String?> generateAssociationKey(String publicUserId) {
    return KeyriPlatform.instance.generateAssociationKey(publicUserId);
  }

  Future<String?> getUserSignature(
      String? publicUserId, String customSignedData) {
    return KeyriPlatform.instance
        .getUserSignature(publicUserId, customSignedData);
  }

  Future<List<String>> listAssociationKey() {
    return KeyriPlatform.instance.listAssociationKey();
  }

  Future<String?> getAssociationKey(String publicUserId) {
    return KeyriPlatform.instance.getAssociationKey(publicUserId);
  }

  Future<Session?> initiateQrSession(
      String appKey, String sessionId, String? publicUserId) {
    return KeyriPlatform.instance
        .initiateQrSession(appKey, sessionId, publicUserId);
  }

  /// To Use this method, make sure your host Activity extended from FlutterFragmentActivity
  Future<bool> initializeDefaultScreen(String sessionId, String payload) {
    return KeyriPlatform.instance.initializeDefaultScreen(sessionId, payload);
  }

  Future<bool> confirmSession(String sessionId, String payload) {
    return KeyriPlatform.instance.confirmSession(sessionId, payload);
  }

  Future<bool> denySession(String sessionId, String payload) {
    return KeyriPlatform.instance.denySession(sessionId, payload);
  }
}
