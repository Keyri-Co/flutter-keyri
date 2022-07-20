import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'keyri_platform_interface.dart';

/// An implementation of [KeyriPlatform] that uses method channels.
class MethodChannelKeyri extends KeyriPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('keyri');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
