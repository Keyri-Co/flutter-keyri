import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyri_v3/keyri.dart';
import 'package:keyri_v3/keyri_fingerprint_event.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  runApp(const MyApp());
}

const String appKey = "[Your app key here]"; // Change it before launch
const String? publicApiKey = null; // Change it before launch, optional
const String? serviceEncryptionKey = null; // Change it before launch, optional
const bool blockEmulatorDetection = true;
const String? publicUserId = null; // Change it before launch, optional

TextEditingController usernameController = TextEditingController();

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
  Keyri keyri = Keyri(appKey,
      publicApiKey: publicApiKey,
      serviceEncryptionKey: serviceEncryptionKey,
      blockEmulatorDetection: true);

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
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: "Enter username",
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  )),
              button(_sendEvent, 'Send event'),
              button(_login, 'Keyri login'),
              button(_attach, 'Keyri attach'),
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

  String _randomHexString(int length) {
    Random random = Random();
    StringBuffer stringBuffer = StringBuffer();

    for (var i = 0; i < length; i++) {
      stringBuffer.write(random.nextInt(16).toRadixString(16));
    }

    return stringBuffer.toString();
  }

  void _generateAssociationKey() {
    keyri
        .generateAssociationKey(publicUserId: usernameController.text)
        .then((key) => _showMessage('Key generated: $key'))
        .catchError((error, stackTrace) => _processError(error));
  }

  void _getAssociationKey() {
    keyri
        .getAssociationKey(publicUserId: usernameController.text)
        .then((key) => _showMessage('Key: $key'))
        .catchError((error, stackTrace) => _processError(error));
  }

  void _generateSignature() {
    int timestamp = DateTime.now().millisecondsSinceEpoch;

    keyri
        .generateUserSignature(
            publicUserId: usernameController.text, data: timestamp.toString())
        .then((signature) => _showMessage('Signature: $signature'))
        .catchError((error, stackTrace) => _processError(error));
  }

  void _removeAssociationKey() {
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
    keyri
        .listAssociationKeys()
        .then((keys) => _showMessage(json.encode(keys)))
        .catchError((error, stackTrace) => _processError(error));
  }

  void _listUniqueAccounts() {
    keyri
        .listUniqueAccounts()
        .then((keys) => _showMessage(json.encode(keys)))
        .catchError((error, stackTrace) => _processError(error));
  }

  void _login() async {
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

      var loginResult =
          LoginResult(timestampNonce, signature!, usernameController.text)
              .toJson();

      keyri
          .easyKeyriAuth(jsonEncode(loginResult),
              publicUserId: usernameController.text)
          .then(
              (authResult) => _onAuthResult(authResult == true ? true : false))
          .catchError((error, stackTrace) => _processError(error));
    } else {
      _showMessage("Account does not exists");
    }
  }

  void _attach() async {
    String? publicKey =
        await keyri.getAssociationKey(publicUserId: usernameController.text);

    if (publicKey == null) {
      publicKey = await keyri.generateAssociationKey(
          publicUserId: usernameController.text);

      var registerResult =
          RegisterResult(publicKey!, usernameController.text).toJson();

      keyri
          .easyKeyriAuth(jsonEncode(registerResult),
              publicUserId: usernameController.text)
          .then(
              (authResult) => _onAuthResult(authResult == true ? true : false))
          .catchError((error, stackTrace) => _processError(error));
    } else {
      _showMessage("Account already exists");
    }
  }

  void _sendEvent() {
    keyri
        .sendEvent(
            publicUserId: usernameController.text,
            eventType: EventType.visits,
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

  void _onAuthResult(bool result) {
    if (result) {
      _showMessage('Successfully authenticated!');
    } else {
      _showMessage('Authentication failed');
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

class KeyriScannerAuthPage extends StatefulWidget {
  const KeyriScannerAuthPage({Key? key}) : super(key: key);

  @override
  State<KeyriScannerAuthPage> createState() => _KeyriScannerAuthPageState();
}

class _KeyriScannerAuthPageState extends State<KeyriScannerAuthPage> {
  bool _isLoading = false;

  Keyri keyri = Keyri(appKey,
      publicApiKey: publicApiKey,
      serviceEncryptionKey: serviceEncryptionKey,
      blockEmulatorDetection: true);

  void onMobileScannerDetect(BarcodeCapture barcodes) {
    if (barcodes.barcodes.isNotEmpty && !_isLoading) {
      var barcode = barcodes.barcodes[0];

      if (barcode.rawValue == null) {
        debugPrint('Failed to scan Barcode');
        return;
      }

      final String? code = barcode.rawValue;
      debugPrint('Scanned barcode: $code');

      if (code == null) return;

      var sessionId = Uri.dataFromString(code).queryParameters['sessionId'];

      if (sessionId == null) return;

      setState(() {
        _isLoading = true;
      });

      _onReadSessionId(sessionId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: _isLoading
                ? const Center(
                    child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [CircularProgressIndicator()]))
                : MobileScanner(onDetect: onMobileScannerDetect),
          )
        ],
      ),
    );
  }

  Future<void> _onReadSessionId(String sessionId) async {
    keyri
        .initiateQrSession(sessionId, publicUserId: usernameController.text)
        .then((session) => keyri
            .initializeDefaultConfirmationScreen('Some payload')
            .then((authResult) => _onAuthResult(authResult))
            .catchError((error, stackTrace) => _onError(error.toString())))
        .catchError((error, stackTrace) => _onError(error.toString()));
  }

  void _onError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));

    Future.delayed(const Duration(milliseconds: 2000), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _onAuthResult(bool result) {
    if (result) {
      _showMessage('Successfully authenticated!');
    } else {
      _showMessage('Authentication failed');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class LoginResult {
  String timestampNonce;
  String signature;
  String email;

  LoginResult(this.timestampNonce, this.signature, this.email);

  Map<String, Object?> toJson() {
    return {
      'timestamp_nonce': timestampNonce,
      'signature': signature,
      'email': email,
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
