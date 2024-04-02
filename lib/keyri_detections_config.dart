/// Class which represents Keyri detections configuration.
/// Configure detections config and specify needed checks.
///
/// blockEmulatorDetection - set this param to false if you want to deny run your app on emulators, true by default.
/// blockRootDetection - set this param to true if you want to allow running your app without rooted device check, false by default.
/// blockDangerousAppsDetection - set this param to true if you want to allow running your app without dangerous apps check, false by default.
/// blockTamperDetection - set this param to true if you want to allow running your app without tamper detection check, false by default.
/// blockSwizzleDetection - set this param to true if you want to allow running your app without swizzle detection check, false by default.
class KeyriDetectionsConfig {
  bool blockEmulatorDetection = true;
  bool blockRootDetection = true;
  bool blockDangerousAppsDetection = true;
  bool blockTamperDetection = true;
  bool blockSwizzleDetection = true;

  KeyriDetectionsConfig(
      {bool? blockEmulatorDetection,
      bool? blockRootDetection,
      bool? blockDangerousAppsDetection,
      bool? blockTamperDetection,
      bool? blockSwizzleDetection}) {
    this.blockEmulatorDetection = blockEmulatorDetection ?? true;
    this.blockRootDetection = blockRootDetection ?? false;
    this.blockDangerousAppsDetection = blockDangerousAppsDetection ?? false;
    this.blockTamperDetection = blockTamperDetection ?? true;
    this.blockSwizzleDetection = blockSwizzleDetection ?? false;
  }
}
