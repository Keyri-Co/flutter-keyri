import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyri_v3/KeyriDetectionsConfig.dart';
import 'package:keyri_v3/keyri.dart';
import 'package:keyri_v3/keyri_fingerprint_event.dart';

void main() {
  runApp(const MyApp());
}

TextEditingController appKeyController = TextEditingController();
TextEditingController publicApiKeyController = TextEditingController();
TextEditingController serviceEncryptionKeyController = TextEditingController();
TextEditingController usernameController = TextEditingController();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Keyri Example',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const KeyriHomePage(title: 'Keyri Example'));
  }
}

class KeyriHomePage extends StatefulWidget {
  const KeyriHomePage({super.key, required this.title});

  final String title;

  @override
  State<KeyriHomePage> createState() => _KeyriHomePageState();
}

class _KeyriHomePageState extends State<KeyriHomePage> {
  final EventType _eventType = EventType.visits();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                // Adjust the horizontal padding as needed
                child: Center(
                  child: Column(
                    children: [
                      TextFormField(
                          controller: appKeyController,
                          decoration: InputDecoration(
                            labelText: "Enter app key",
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          )),
                      const SizedBox(height: 5),
                      TextFormField(
                          controller: publicApiKeyController,
                          decoration: InputDecoration(
                            labelText: "Enter public API key",
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          )),
                      const SizedBox(height: 5),
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
                    ],
                  ),
                ),
              ),
              button(_sendEvent, 'Send event'),
              button(_login, 'Login'),
              button(_register, 'Register'),
              button(_getCorrectedTimestampSeconds, 'Get timestamp'),
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

      return Keyri.primary(appKey,
          publicApiKey: publicApiKey,
          serviceEncryptionKey: serviceEncryptionKey,
          detectionsConfig: KeyriDetectionsConfig(blockTamperDetection: true));
    } else {
      _showMessage('App key is required!');
    }

    return null;
  }

  Future<void> _login() async {
    Keyri? keyri = initKeyri();

    if (keyri == null) return;

    String? publicUserId = usernameController.text;

    if (publicUserId.isEmpty) {
      publicUserId = null;
    }

    keyri
        .login(publicUserId: publicUserId)
        .then((loginObject) =>
            _showMessage('Login object: ${json.encode(loginObject.toJson())}'))
        .catchError((error, stackTrace) => _processError(error));
  }

  Future<void> _register() async {
    Keyri? keyri = initKeyri();

    if (keyri == null) return;

    String? publicUserId = usernameController.text;

    if (publicUserId.isEmpty) {
      publicUserId = null;
    }

    keyri
        .register(publicUserId: publicUserId)
        .then((registerObject) => _showMessage(
            'Register object: ${json.encode(registerObject.toJson())}'))
        .catchError((error, stackTrace) => _processError(error));
  }

  Future<void> _getCorrectedTimestampSeconds() async {
    Keyri? keyri = initKeyri();

    if (keyri == null) return;

    String? publicUserId = usernameController.text;

    if (publicUserId.isEmpty) {
      publicUserId = null;
    }

    keyri
        .getCorrectedTimestampSeconds()
        .then((timestamp) => _showMessage('Timestamp: $timestamp'))
        .catchError((error, stackTrace) => _processError(error));
  }

  void _generateAssociationKey() {
    Keyri? keyri = initKeyri();

    if (keyri == null) return;

    String? publicUserId = usernameController.text;

    if (publicUserId.isEmpty) {
      publicUserId = null;
    }

    keyri
        .generateAssociationKey(publicUserId: publicUserId)
        .then((key) => _showMessage('Key generated: $key'))
        .catchError((error, stackTrace) => _processError(error));
  }

  void _getAssociationKey() {
    Keyri? keyri = initKeyri();

    if (keyri == null) return;

    String? publicUserId = usernameController.text;

    if (publicUserId.isEmpty) {
      publicUserId = null;
    }

    keyri
        .getAssociationKey(publicUserId: publicUserId)
        .then((key) => _showMessage('Key: $key'))
        .catchError((error, stackTrace) => _processError(error));
  }

  void _generateSignature() {
    Keyri? keyri = initKeyri();

    if (keyri == null) return;

    int timestamp = DateTime.now().millisecondsSinceEpoch;

    String? publicUserId = usernameController.text;

    if (publicUserId.isEmpty) {
      publicUserId = null;
    }

    keyri
        .generateUserSignature(
            publicUserId: publicUserId, data: timestamp.toString())
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

  void _sendEvent() async {
    Keyri? keyri = initKeyri();

    if (keyri == null) return;

    String? publicUserId = usernameController.text;

    if (publicUserId.isEmpty) {
      publicUserId = null;
    }

    keyri
        .sendEvent(
            publicUserId: usernameController.text,
            eventType: _eventType,
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
