import 'dart:convert';

/// Class which represents login object.
class LoginObject {
  LoginObject(this.timestampNonce, this.signature, this.publicKey, this.userId);

  final String timestampNonce;
  final String signature;
  final String publicKey;
  final String userId;

  /// Conversion helper method.
  Map<String, dynamic> toJson() {
    return {
      'timestampNonce': timestampNonce,
      'signature': signature,
      'publicKey': publicKey,
      'userId': userId,
    };
  }

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
      jsonData['timestampNonce'] as String,
      jsonData['signature'] as String,
      jsonData['publicKey'] as String,
      jsonData['userId'] as String,
    );
  }
}
