import 'package:flutter/material.dart';
import 'package:keyri/keyri.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


Future<void> main() async {
  await Supabase.initialize(
    url: 'https://pidfgjqywchqcqdjhmsj.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBpZGZnanF5d2NocWNxZGpobXNqIiwicm9sZSI6ImFub24iLCJpYXQiOjE2NTQ3NzQzNTUsImV4cCI6MTk3MDM1MDM1NX0.HY0mpzolDkg5TZ7_gim6i0mzXKbhCtIMJptgLcvdZv8',
  );
  runApp(const MyApp());
}

const String appKey = 'raB7SFWt27woKqkPhaUrmWAsCJIO8Moj'; // from Keyri Dev Portal


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
  Keyri keyri = Keyri();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            button(_easyKeyriAuth, 'Easy Keyri Auth'),
          ],
        ),
      ),
    );
  }

  void _easyKeyriAuth() async {
    final supabase = Supabase.instance.client;
    final res = await supabase.auth.signIn(email:"newUser123@gmail.com", password: "123test456");
    final token = res.data!.refreshToken;
    final payload = "{${'"'}refreshToken${'"'}: ${'"'}${token}${'"'}}";
    // {"refreshToken": "[token]"}

    await keyri
        .easyKeyriAuth(appKey, payload, 'newUser123@gmail.com')
        .then((authResult) => _onAuthResult(authResult == true ? true : false))
        .catchError((error, stackTrace) => _onError(error));
  }

  void _onError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _onAuthResult(bool result) {
    String text;
    if (result) {
      text = 'Successfully authenticated!';
    } else {
      text = 'Authentication failed';
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Widget button(VoidCallback onPressedCallback, String text) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Colors.deepPurple,
        onPrimary: Colors.white,
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

  Keyri keyri = Keyri();

  void onMobileScannerDetect(Barcode barcode, MobileScannerArguments? args) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: _isLoading
                ? Center(
                    child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [CircularProgressIndicator()]))
                : MobileScanner(allowDuplicates: false, onDetect: onMobileScannerDetect),
          )
        ],
      ),
    );
  }

  Future<void> _onReadSessionId(String sessionId) async {
    await keyri
        .initiateQrSession(appKey, sessionId, 'Public user ID')
        .then((session) => keyri
            .initializeDefaultScreen(sessionId, 'Some payload')
            .then((authResult) => _onAuthResult(authResult))
            .catchError((error, stackTrace) => _onError(error.toString())))
        .catchError((error, stackTrace) => _onError(error.toString()));
  }

  void _onError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

    setState(() {
      _isLoading = false;
    });
  }

  void _onAuthResult(bool result) {
    String text;

    if (result) {
      text = 'Successfully authenticated!';
    } else {
      text = 'Failed to authenticate';
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

    setState(() {
      _isLoading = false;
    });
  }
}
