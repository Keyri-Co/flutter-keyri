import 'package:flutter_test/flutter_test.dart';
import 'package:keyri/keyri.dart';
import 'package:keyri/keyri_platform_interface.dart';
import 'package:keyri/keyri_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockKeyriPlatform 
    with MockPlatformInterfaceMixin
    implements KeyriPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final KeyriPlatform initialPlatform = KeyriPlatform.instance;

  test('$MethodChannelKeyri is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelKeyri>());
  });

  test('getPlatformVersion', () async {
    Keyri keyriPlugin = Keyri();
    MockKeyriPlatform fakePlatform = MockKeyriPlatform();
    KeyriPlatform.instance = fakePlatform;
  
    expect(await keyriPlugin.getPlatformVersion(), '42');
  });
}
