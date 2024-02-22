import 'dart:convert';

/// Class which represents fingerprint request object.
class FingerprintRequest {
  FingerprintRequest(
      this.clientEncryptionKey, this.encryptedPayload, this.salt, this.iv);

  final String clientEncryptionKey;
  final String encryptedPayload;
  final String salt;
  final String iv;

  /// Conversion helper method.
  static FingerprintRequest fromJson(dynamic json) {
    dynamic jsonData = json;

    try {
      String jsonDataString = json.toString();
      jsonData = jsonDecode(jsonDataString);
    } catch (e) {
      jsonData = json;
    }

    return FingerprintRequest(
        jsonData['clientEncryptionKey'] as String,
        jsonData['encryptedPayload'] as String,
        jsonData['salt'] as String,
        jsonData['iv'] as String);
  }
}
