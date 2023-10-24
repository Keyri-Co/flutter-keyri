import 'dart:convert';

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            button(_easyKeyriAuth, 'Easy Keyri Auth'),
            button(_customUI, 'Custom UI'),
            button(_sendEvent, 'Send event'),
            button(_generateAssociationKey, 'Generate association key'),
            button(_getAssociationKey, 'Get association key'),
            button(_removeAssociationKey, 'Remove association key'),
            button(_listAssociationKeys, 'List association keys'),
            button(_listUniqueAccounts, 'List unique accounts'),
            button(_generateSignature, 'Generate signature')
          ],
        ),
      ),
    );
  }

  void _generateAssociationKey() {
    keyri
        .generateAssociationKey(publicUserId: publicUserId)
        .then((key) => _showMessage('Key generated: $key'))
        .catchError((error, stackTrace) => _processError(error));
  }

  void _getAssociationKey() {
    keyri
        .getAssociationKey(publicUserId: publicUserId)
        .then((key) => _showMessage('Key: $key'))
        .catchError((error, stackTrace) => _processError(error));
  }

  void _generateSignature() {
    int timestamp = DateTime.now().millisecondsSinceEpoch;

    keyri
        .generateUserSignature(
            publicUserId: publicUserId, data: timestamp.toString())
        .then((signature) => _showMessage('Signature: $signature'))
        .catchError((error, stackTrace) => _processError(error));
  }

  void _removeAssociationKey() {
    String? userId = publicUserId;

    if (userId != null) {
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

  void _easyKeyriAuth() {
    keyri
        .easyKeyriAuth('Some payload', publicUserId: publicUserId)
        .then((authResult) => _onAuthResult(authResult == true ? true : false))
        .catchError((error, stackTrace) => _processError(error));
  }

  void _sendEvent() {
    keyri
        .sendEvent(
            publicUserId: publicUserId,
            eventType: EventType.visits,
            success: true)
        .then((fingerprintEventResponse) => _showMessage("Event sent"))
        .catchError((error, stackTrace) => _processError(error));
  }

  void _customUI() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const KeyriScannerAuthPage()));
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
        .initiateQrSession(sessionId, publicUserId: publicUserId)
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
