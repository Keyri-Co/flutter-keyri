
import 'keyri_platform_interface.dart';

class Keyri {
  Future<String?> getPlatformVersion() {
    return KeyriPlatform.instance.getPlatformVersion();
  }
}
