import 'dart:convert';

class FingerprintEventResponse {
  FingerprintEventResponse(this.apiCiphertextSignature,
      this.publicEncryptionKey, this.ciphertext, this.iv, this.salt);

  final String apiCiphertextSignature;
  final String publicEncryptionKey;
  final String ciphertext;
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
        jsonData['apiCiphertextSignature'] as String,
        jsonData['publicEncryptionKey'] as String,
        jsonData['ciphertext'] as String,
        jsonData['iv'] as String,
        jsonData['salt'] as String);
  }
}
