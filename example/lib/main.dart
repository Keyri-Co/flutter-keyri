import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyri_v3/keyri.dart';
import 'package:keyri_v3/keyri_fingerprint_event.dart';

void main() {
  runApp(const MyApp());
}

TextEditingController appKeyController = TextEditingController();
TextEditingController publicApiKeyController = TextEditingController();
TextEditingController serviceEncryptionKeyController = TextEditingController();
TextEditingController usernameController = TextEditingController();
String eventType = "visits";

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Keyri Example',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const KeyriHomePage(title: 'Keyri Example'));
  }
}

class KeyriHomePage extends StatefulWidget {
  const KeyriHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<KeyriHomePage> createState() => _KeyriHomePageState();
}

class _KeyriHomePageState extends State<KeyriHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                  controller: appKeyController,
                  decoration: InputDecoration(
                    labelText: "Enter app key",
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  )),
              TextFormField(
                  controller: publicApiKeyController,
                  decoration: InputDecoration(
                    labelText: "Enter public API key",
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  )),
              TextFormField(
                  controller: serviceEncryptionKeyController,
                  decoration: InputDecoration(
                    labelText: "Enter service encryption key",
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  )),
              const SizedBox(height: 30),
              TextFormField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: "Enter username",
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  )),
              DropdownButton<String>(
                items: EventType.values
                    .map((etValue) => etValue.name)
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    eventType = value;
                  }
                },
              ),
              button(_sendEvent, 'Send event'),
              button(_login, 'Login'),
              button(_register, 'Register'),
              button(_generateAssociationKey, 'Generate association key'),
              button(_getAssociationKey, 'Get association key'),
              button(_removeAssociationKey, 'Remove association key'),
              button(_listAssociationKeys, 'List association keys'),
              button(_listUniqueAccounts, 'List unique accounts'),
              button(_generateSignature, 'Generate signature')
            ],
          ),
        ),
      ),
    );
  }

  Keyri? initKeyri() {
    var appKey = appKeyController.text;
    String? publicApiKey = publicApiKeyController.text;
    String? serviceEncryptionKey = serviceEncryptionKeyController.text;

    if (appKey.isNotEmpty) {
      if (publicApiKey.isEmpty) {
        publicApiKey = null;
      }

      if (serviceEncryptionKey.isEmpty) {
        serviceEncryptionKey = null;
      }

      return Keyri(appKey,
          publicApiKey: publicApiKey,
          serviceEncryptionKey: serviceEncryptionKey,
          blockEmulatorDetection: true);
    } else {
      _showMessage('App key is required!');
    }

    return null;
  }

  Future<void> _login() async {
    Keyri? keyri = initKeyri();

    if (keyri == null) return;

    String? publicKey =
        await keyri.getAssociationKey(publicUserId: usernameController.text);

    if (publicKey != null) {
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

      String random = _randomHexString(16);
      Codec<String, String> stringToBase64 = utf8.fuse(base64);
      String nonce = stringToBase64.encode(random);

      String timestampNonce = "${timestamp}_$nonce";

      String? signature = await keyri.generateUserSignature(
          publicUserId: usernameController.text, data: timestampNonce);

      if (usernameController.text.isEmpty) {
        _showMessage('Login result:\npublicUserId should not be null');
      }

      var loginResult = LoginResult(
              timestampNonce, signature!, publicKey, usernameController.text)
          .toJson();

      _showMessage('Login result:\n$loginResult');
    } else {
      _showMessage(
          'Login result:\n${usernameController.text} does not exists on the device');
    }
  }

  Future<void> _register() async {
    Keyri? keyri = initKeyri();

    if (keyri == null) return;

    String? publicKey =
        await keyri.getAssociationKey(publicUserId: usernameController.text);

    if (publicKey == null) {
      publicKey = await keyri.generateAssociationKey(
          publicUserId: usernameController.text);

      var registerResult =
          RegisterResult(publicKey!, usernameController.text).toJson();

      _showMessage('Register result:\n$registerResult');
    } else {
      _showMessage(
          'Register result:\n${usernameController.text} already exists');
    }
  }

  String _randomHexString(int length) {
    Random random = Random();
    StringBuffer stringBuffer = StringBuffer();

    for (var i = 0; i < length; i++) {
      stringBuffer.write(random.nextInt(16).toRadixString(16));
    }

    return stringBuffer.toString();
  }

  void _generateAssociationKey() {
    Keyri? keyri = initKeyri();

    if (keyri == null) return;

    keyri
        .generateAssociationKey(publicUserId: usernameController.text)
        .then((key) => _showMessage('Key generated: $key'))
        .catchError((error, stackTrace) => _processError(error));
  }

  void _getAssociationKey() {
    Keyri? keyri = initKeyri();

    if (keyri == null) return;

    keyri
        .getAssociationKey(publicUserId: usernameController.text)
        .then((key) => _showMessage('Key: $key'))
        .catchError((error, stackTrace) => _processError(error));
  }

  void _generateSignature() {
    Keyri? keyri = initKeyri();

    if (keyri == null) return;

    int timestamp = DateTime.now().millisecondsSinceEpoch;

    keyri
        .generateUserSignature(
            publicUserId: usernameController.text, data: timestamp.toString())
        .then((signature) => _showMessage('Signature: $signature'))
        .catchError((error, stackTrace) => _processError(error));
  }

  void _removeAssociationKey() {
    Keyri? keyri = initKeyri();

    if (keyri == null) return;

    String? userId = usernameController.text;

    if (userId.isNotEmpty) {
      keyri
          .removeAssociationKey(userId)
          .then((_) => _showMessage('Key removed'))
          .catchError((error, stackTrace) => _processError(error));
    } else {
      _showMessage('publicUserId shouldn\'t be null');
    }
  }

  void _listAssociationKeys() {
    Keyri? keyri = initKeyri();

    if (keyri == null) return;

    keyri
        .listAssociationKeys()
        .then((keys) => _showMessage(json.encode(keys)))
        .catchError((error, stackTrace) => _processError(error));
  }

  void _listUniqueAccounts() {
    Keyri? keyri = initKeyri();

    if (keyri == null) return;

    keyri
        .listUniqueAccounts()
        .then((keys) => _showMessage(json.encode(keys)))
        .catchError((error, stackTrace) => _processError(error));
  }

  void _sendEvent() {
    Keyri? keyri = initKeyri();

    if (keyri == null) return;

    keyri
        .sendEvent(
            publicUserId: usernameController.text,
            eventType: EventType.values
                .firstWhere((element) => element.name == eventType),
            success: true)
        .then((fingerprintEventResponse) => _showMessage("Event sent"))
        .catchError((error, stackTrace) => _processError(error));
  }

  void _processError(dynamic error) {
    if (error is PlatformException) {
      _showMessage(error.message ?? "Error occurred");
    } else {
      _showMessage(error.toString());
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Widget button(VoidCallback onPressedCallback, String text) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.deepPurple,
      ),
      onPressed: onPressedCallback,
      child: Text(text),
    );
  }
}

class LoginResult {
  String timestampNonce;
  String signature;
  String publicKey;
  String userId;

  LoginResult(this.timestampNonce, this.signature, this.publicKey, this.userId);

  Map<String, Object?> toJson() {
    return {
      'timestamp_nonce': timestampNonce,
      'signature': signature,
      'publicKey': publicKey,
      'userId': userId
    };
  }
}

class RegisterResult {
  String publicKey;
  String userId;

  RegisterResult(this.publicKey, this.userId);

  Map<String, Object?> toJson() {
    return {'publicKey': publicKey, 'userId': userId};
  }
}
