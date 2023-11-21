import 'dart:convert';

/// Class which represents login object.
class LoginObject {
  LoginObject(this.timestamp_nonce, this.signature, this.publicKey,
      this.userId);

  final String timestamp_nonce;
  final String signature;
  final String publicKey;
  final String userId;

  /// Conversion helper method.
  static LoginObject fromJson(dynamic json) {
    dynamic jsonData = json;

    try {
      String jsonDataString = json.toString();
      jsonData = jsonDecode(jsonDataString);
    } catch (e) {
      jsonData = json;
    }

    return LoginObject(
      jsonData['timestamp_nonce'] as String,
      jsonData['signature'] as String,
      jsonData['publicKey'] as String,
      jsonData['userId'] as String,
    );
  }
}
