import 'package:keyri_v3/fingerprint_event_response.dart';
import 'package:keyri_v3/fingerprint_request.dart';
import 'package:keyri_v3/register_object.dart';
import 'package:keyri_v3/session.dart';
import 'keyri_detections_config.dart';
import 'keyri_fingerprint_event.dart';
import 'login_object.dart';
import 'src/keyri_platform_interface.dart';

///
/// Keyri plugin. This class represents Keyri SDK for passwordless QR authentication.
///
class Keyri {
  String _appKey = '';
  String? _publicApiKey;
  String? _serviceEncryptionKey;
  KeyriDetectionsConfig _detectionsConfig = KeyriDetectionsConfig();

  /// Pass required appKey for given Origin.
  /// Provide optional publicApiKey and serviceEncryptionKey parameters to use fraud prevention and mobile fingerprinting.
  /// Set blockEmulatorDetection parameter to false if you want to deny run your app on emulators, true by default.
  @Deprecated(
      "This constructor is deprecated. Use Keyri.primary constructor with KeyriDetectionsConfig param")
  Keyri(appKey,
      {String? publicApiKey,
      String? serviceEncryptionKey,
      bool? blockEmulatorDetection}) {
    _appKey = appKey;
    _publicApiKey = publicApiKey;
    _serviceEncryptionKey = serviceEncryptionKey;

    Keyri.primary(appKey,
        publicApiKey: _publicApiKey,
        serviceEncryptionKey: _serviceEncryptionKey,
        detectionsConfig: KeyriDetectionsConfig(
            blockEmulatorDetection: blockEmulatorDetection));
  }

  /// Pass required appKey for given Origin.
  /// Provide optional publicApiKey and serviceEncryptionKey parameters to use fraud prevention and mobile fingerprinting.
  /// Set blockEmulatorDetection parameter to false if you want to deny run your app on emulators, true by default.
  Keyri.primary(appKey,
      {String? publicApiKey,
      String? serviceEncryptionKey,
      KeyriDetectionsConfig? detectionsConfig}) {
    _appKey = appKey;
    _publicApiKey = publicApiKey;
    _serviceEncryptionKey = serviceEncryptionKey;

    if (detectionsConfig != null) {
      _detectionsConfig = detectionsConfig;
    }

    if (_appKey.isEmpty) {
      throw Exception('You need to specify appKey');
    }

    KeyriPlatform.instance
        .initialize(
            _appKey, _publicApiKey, _serviceEncryptionKey, _detectionsConfig)
        .then((isInitialized) => {
              if (!isInitialized)
                {throw Exception('Failed to initialize Keyri')}
            });
  }

  /// Call this method to launch in-app scanner and delegate authentication to SDK.
  Future<bool> easyKeyriAuth(String payload, {String? publicUserId}) {
    return KeyriPlatform.instance.easyKeyriAuth(_appKey, _publicApiKey,
        _serviceEncryptionKey, _detectionsConfig, payload, publicUserId);
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
  /// Returns [FingerprintEventResponse] or error.
  Future<FingerprintEventResponse> sendEvent(
      {String? publicUserId,
      required EventType eventType,
      required bool success}) {
    return KeyriPlatform.instance.sendEvent(publicUserId, eventType, success);
  }

  /// Creates and returns fingerprint event object.
  /// Returns [FingerprintRequest] or error.
  Future<FingerprintRequest> createFingerprint() {
    return KeyriPlatform.instance.createFingerprint();
  }

  /// Call it after obtaining the sessionId from QR code or deep link.
  /// Returns Future of [Session] object with Risk attributes (needed to show confirmation screen) or error.
  Future<Session> initiateQrSession(String sessionId, {String? publicUserId}) {
    return KeyriPlatform.instance.initiateQrSession(sessionId, publicUserId);
  }

  /// Call it to create [LoginObject] for login.
  /// Returns Future of [LoginObject] object or error.
  Future<LoginObject> login({String? publicUserId}) {
    return KeyriPlatform.instance.login(publicUserId);
  }

  /// Call it to create [RegisterObject] for login.
  /// Returns Future of [RegisterObject] object or error.
  Future<RegisterObject> register({String? publicUserId}) {
    return KeyriPlatform.instance.register(publicUserId);
  }

  /// Call it to get timestamp synchronized with NTP.
  /// Returns Future of [int] or error.
  Future<int> getCorrectedTimestampSeconds() {
    return KeyriPlatform.instance.getCorrectedTimestampSeconds();
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
