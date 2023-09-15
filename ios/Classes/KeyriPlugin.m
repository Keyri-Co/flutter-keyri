#import "KeyriPlugin.h"
#if __has_include(<keyri/Keyri-Swift.h>)
#import <keyri/Keyri-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "Keyri-Swift.h"
#endif

@implementation KeyriPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftKeyriPlugin registerWithRegistrar:registrar];
}
@end
