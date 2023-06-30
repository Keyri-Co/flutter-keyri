import 'dart:convert';

class FingerprintEventResponse {
  FingerprintEventResponse(
      this.keyriEncryptionPublicKey, this.encryptedPayload, this.iv, this.salt);

  final String keyriEncryptionPublicKey;
  final String encryptedPayload;
  final String iv;
  final String salt;

  static FingerprintEventResponse fromJson(dynamic json) {
    dynamic jsonData = json;

    try {
      String jsonDataString = json.toString();
      jsonData = jsonDecode(jsonDataString);
    } catch (e) {
      jsonData = json;
    }

    return FingerprintEventResponse(
        jsonData['keyriEncryptionPublicKey'] as String,
        jsonData['encryptedPayload'] as String,
        jsonData['iv'] as String,
        jsonData['salt'] as String);
  }
}
