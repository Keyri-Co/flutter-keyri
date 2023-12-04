import 'dart:convert';

/// Class which represents register object.
class RegisterObject {
  RegisterObject(this.publicKey, this.userId);

  final String publicKey;
  final String userId;

  /// Conversion helper method.
  Map<String, dynamic> toJson() {
    return {
      'publicKey': publicKey,
      'userId': userId,
    };
  }

  /// Conversion helper method.
  static RegisterObject fromJson(dynamic json) {
    dynamic jsonData = json;

    try {
      String jsonDataString = json.toString();
      jsonData = jsonDecode(jsonDataString);
    } catch (e) {
      jsonData = json;
    }

    return RegisterObject(
      jsonData['publicKey'] as String,
      jsonData['userId'] as String,
    );
  }
}
