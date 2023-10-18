import 'package:keyri_v3/fingerprint_event_response.dart';
import 'package:keyri_v3/session.dart';

import 'keyri_fingerprint_event.dart';
import 'src/keyri_platform_interface.dart';

///
/// Keyri plugin. This class represents Keyri SDK for passwordless QR authentication.
///
class Keyri {
  String _appKey = '';
  String? _publicApiKey;
  String? _serviceEncryptionKey;
  bool _blockEmulatorDetection = true;

  /// Pass required appKey for given Origin.
  /// Provide optional publicApiKey and serviceEncryptionKey parameters to use fraud prevention and mobile fingerprinting.
  /// Set blockEmulatorDetection parameter to false if you want to deny run your app on emulators, true by default.
  Keyri(appKey,
      {String? publicApiKey,
      String? serviceEncryptionKey,
      bool? blockEmulatorDetection}) {
    _appKey = appKey;
    _publicApiKey = publicApiKey;
    _serviceEncryptionKey = serviceEncryptionKey;
    _blockEmulatorDetection = blockEmulatorDetection ?? true;

    if (_appKey.isEmpty) {
      throw Exception('You need to specify appKey');
    }

    KeyriPlatform.instance
        .initialize(_appKey, _publicApiKey, _serviceEncryptionKey,
            _blockEmulatorDetection)
        .then((isInitialized) => {
              if (!isInitialized)
                {throw Exception('Failed to initialize Keyri')}
            });
  }

  /// Call this method to launch in-app scanner and delegate authentication to SDK.
  Future<bool> easyKeyriAuth(String payload, {String? publicUserId}) {
    return KeyriPlatform.instance.easyKeyriAuth(_appKey, _publicApiKey,
        _serviceEncryptionKey, _blockEmulatorDetection, payload, publicUserId);
  }

  /// Returns Base64 public key for the specified publicUserId.
  Future<String?> generateAssociationKey({String? publicUserId}) {
    return KeyriPlatform.instance.generateAssociationKey(publicUserId);
  }

  /// Returns an Base64 ECDSA signature of the optional customSignedData with the publicUserId's
  /// privateKey (or, if not provided, anonymous privateKey), data can be anything.
  Future<String?> generateUserSignature(
      {String? publicUserId, required String data}) {
    return KeyriPlatform.instance.generateUserSignature(publicUserId, data);
  }

  /// Returns a map of "association keys" and ECDSA Base64 public keys.
  Future<Map<String, String>> listAssociationKeys() {
    return KeyriPlatform.instance.listAssociationKeys();
  }

  /// Returns a map of unique "association keys" and ECDSA Base64 public keys.
  Future<Map<String, String>> listUniqueAccounts() {
    return KeyriPlatform.instance.listUniqueAccounts();
  }

  /// Returns association Base64 public key for the specified publicUserId's.
  Future<String?> getAssociationKey({String? publicUserId}) {
    return KeyriPlatform.instance.getAssociationKey(publicUserId);
  }

  /// Removes association public key for the specified publicUserId's.
  Future<bool> removeAssociationKey(String publicUserId) {
    return KeyriPlatform.instance.removeAssociationKey(publicUserId);
  }

  /// Sends fingerprint event and event result for specified publicUserId's.
  /// Return [FingerprintEventResponse] or error.
  Future<FingerprintEventResponse> sendEvent(
      {String? publicUserId,
      required EventType eventType,
      required bool success}) {
    return KeyriPlatform.instance.sendEvent(publicUserId, eventType, success);
  }

  /// Call it after obtaining the sessionId from QR code or deep link.
  /// Returns Future of [Session] object with Risk attributes (needed to show confirmation screen) or error.
  Future<Session> initiateQrSession(String sessionId, {String? publicUserId}) {
    return KeyriPlatform.instance.initiateQrSession(sessionId, publicUserId);
  }

  /// Call it to show Confirmation screen with default UI.
  Future<bool> initializeDefaultConfirmationScreen(String payload) {
    return KeyriPlatform.instance.initializeDefaultConfirmationScreen(payload);
  }

  /// Call it to process scanned link with sessionId and show Confirmation with default UI.
  Future<bool> processLink(String link, String payload,
      {String? publicUserId}) {
    return KeyriPlatform.instance.processLink(link, payload, publicUserId);
  }

  /// Call this function if user confirmed the dialog. Returns Boolean authentication result.
  Future<bool> confirmSession(String payload, bool trustNewBrowser) {
    return KeyriPlatform.instance.confirmSession(payload, trustNewBrowser);
  }

  /// Call if the user denied the dialog. Returns Boolean denial result.
  Future<bool> denySession(String payload) {
    return KeyriPlatform.instance.denySession(payload);
  }
}
