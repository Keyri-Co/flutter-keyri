#import "KeyriPlugin.h"
#import <keyri_v3-Swift.h>

@implementation KeyriPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    [SwiftKeyriPlugin registerWithRegistrar:registrar];
}
@end
