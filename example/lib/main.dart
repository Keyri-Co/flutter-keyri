import 'package:flutter/material.dart';
import 'package:keyri/keyri.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Keyri SDK',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const KeyriHomePage(title: 'Keyri SDK'));
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
            button(_customUI, 'Custom UI')
          ],
        ),
      ),
    );
  }

  void _easyKeyriAuth() async {
    await keyri
        .easyKeyriAuth('IT7VrTQ0r4InzsvCNJpRCRpi1qzfgpaj', 'Some payload',
            'Public user ID')
        .then((authResult) => _onAuthResult(authResult))
        .catchError((error, stackTrace) {
      _onError(error);
    });
  }

  void _customUI() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const KeyriScannerAuthPage()));
  }

  void _onError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
                : MobileScanner(
                    allowDuplicates: false,
                    onDetect: (barcode, args) {
                      if (barcode.rawValue == null) {
                        debugPrint('Failed to scan Barcode');
                      } else {
                        final String? code = barcode.rawValue;
                        debugPrint('Scanned barcode: $code');

                        if (code != null) {
                          var sessionId = Uri.dataFromString(code)
                              .queryParameters['sessionId'];

                          if (sessionId != null) {
                            setState(() {
                              _isLoading = true;
                            });

                            _onReadSessionId(sessionId);
                          }
                        }
                      }
                    }),
          )
        ],
      ),
    );
  }

  Future<void> _onReadSessionId(String sessionId) async {
    await keyri
        .initiateQrSession(
            'IT7VrTQ0r4InzsvCNJpRCRpi1qzfgpaj', sessionId, 'Public user ID')
        .then((session) => keyri
                .initializeDefaultScreen(sessionId, 'Some payload')
                .then((authResult) => _onAuthResult(authResult))
                .catchError((error, stackTrace) {
              _onError(error.toString());
            }))
        .catchError((error, stackTrace) {
      _onError(error.toString());
    });
  }

  void _onError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));

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
