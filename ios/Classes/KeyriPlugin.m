#import "KeyriPlugin.h"
#import <objc/runtime.h>
@import Keyri;

@interface KeyriPlugin ()

@property (nonatomic, strong) KeyriObjC *keyri;
@property (nonatomic, strong) Session *activeSession;

@end

// TODO: Fix event type error
// TODO: Use FlutterError to process errors and test it
// TODO: Make methods ordering same on all platforms and in documentation

@implementation KeyriPlugin

// TODO: Need to double-check on EasyKeyriAuth results
+ (BOOL)requiresMainQueueSetup
{
    return NO;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
            methodChannelWithName:@"keyri"
                  binaryMessenger:[registrar messenger]];
    KeyriPlugin* instance = [[KeyriPlugin alloc] init];

    instance.keyri = [[KeyriObjC alloc] init];
    instance.activeSession = [[Session alloc] init];

    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"initialize" isEqualToString:call.method]) {
        [self initialize:call result:result];
    } else if ([@"easyKeyriAuth" isEqualToString:call.method]) {
        [self easyKeyriAuth:call result:result];
    } else if ([@"generateAssociationKey" isEqualToString:call.method]) {
        [self generateAssociationKey:call result:result];
    } else if ([@"generateUserSignature" isEqualToString:call.method]) {
        [self generateUserSignature:call result:result];
    } else if ([@"listAssociationKeys" isEqualToString:call.method]) {
        [self listAssociationKeys:call result:result];
    } else if ([@"listUniqueAccounts" isEqualToString:call.method]) {
        [self listUniqueAccounts:call result:result];
    } else if ([@"getAssociationKey" isEqualToString:call.method]) {
        [self getAssociationKey:call result:result];
    } else if ([@"removeAssociationKey" isEqualToString:call.method]) {
        [self removeAssociationKey:call result:result];
    } else if ([@"sendEvent" isEqualToString:call.method]) {
        [self sendEvent:call result:result];
    } else if ([@"initiateQrSession" isEqualToString:call.method]) {
        [self initiateQrSession:call result:result];
        // TODO: Uncomment when available
//    } else if ([@"login" isEqualToString:call.method]) {
//        [self login:call result:result];
//    } else if ([@"register" isEqualToString:call.method]) {
//        [self register:call result:result];
    } else if ([@"initializeDefaultConfirmationScreen" isEqualToString:call.method]) {
        [self initializeDefaultConfirmationScreen:call result:result];
    } else if ([@"processLink" isEqualToString:call.method]) {
        [self processLink:call result:result];
    } else if ([@"confirmSession" isEqualToString:call.method]) {
        [self confirmSession:call result:result];
    } else if ([@"denySession" isEqualToString:call.method]) {
        [self denySession:call result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)initialize:(FlutterMethodCall*)call result:(FlutterResult)result {
    id appKey = call.arguments[@"appKey"];
    id publicApiKeyValue = call.arguments[@"publicApiKey"];
    id serviceEncryptionKeyValue = call.arguments[@"serviceEncryptionKey"];

    if (appKey == nil || ![appKey isKindOfClass:[NSString class]]) {
        // TODO: Check returning in this way
        // TODO: If not working -> add below 'return;'

        // TODO: Test sending error
        return result(@"You need to provide appKey");
    }

    NSString *publicApiKey = [publicApiKeyValue isKindOfClass:[NSString class]] ? publicApiKeyValue : nil;
    NSString *serviceEncryptionKey = [serviceEncryptionKeyValue isKindOfClass:[NSString class]] ? serviceEncryptionKeyValue : nil;

    [self.keyri initializeKeyriWithAppKey:appKey publicAPIKey:publicApiKey serviceEncryptionKey:serviceEncryptionKey];
    result(@(YES));
}

- (void)easyKeyriAuth:(FlutterMethodCall*)call result:(FlutterResult)result {
    id publicUserIdValue = call.arguments[@"publicUserId"];
    id payload = call.arguments[@"payload"];

    if (payload == nil || ![payload isKindOfClass:[NSString class]]) {
        return result(@"You need to provide payload");
    }

    NSString *publicUserId = [publicUserIdValue isKindOfClass:[NSString class]] ? publicUserIdValue : nil;

    dispatch_async(dispatch_get_main_queue(), ^{
        __weak typeof (self) weakSelf = self;
        [self.keyri easyKeyriAuthWithPayload:payload publicUserId:publicUserId completion:^(BOOL success, NSError * _Nullable error) {
            typeof (self) strongSelf = weakSelf;
            if (error != nil) {
                return result(error);
            }

            result(@(success));
        }];
    });
}

- (void)generateAssociationKey:(FlutterMethodCall*)call result:(FlutterResult)result {
    id publicUserIdValue = call.arguments[@"publicUserId"];

    NSString *publicUserId = [publicUserIdValue isKindOfClass:[NSString class]] ? publicUserIdValue : nil;

    [self.keyri generateAssociationKeyWithPublicUserId:publicUserId completion:^(NSString * _Nullable generatedKey, NSError * _Nullable error) {
        if (generatedKey != nil) {
            result(generatedKey);
        } else {
            result(error);
        }
    }];
}

- (void)generateUserSignature:(FlutterMethodCall*)call result:(FlutterResult)result {
    id dataValue = call.arguments[@"data"];
    id publicUserIdValue = call.arguments[@"publicUserId"];

    if (![dataValue isKindOfClass:[NSString class]]) {
        return result(@"You need to provide valid data as a string");
    }

    NSString *dataString = (NSString *)dataValue;
    NSData *dataToSign = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *publicUserId = [publicUserIdValue isKindOfClass:[NSString class]] ? publicUserIdValue : nil;

    if (dataToSign == nil) {
        return result(@"Failed to convert data to NSData");
    }

    [self.keyri generateUserSignatureWithPublicUserId:publicUserId data:dataToSign completion:^(NSString * _Nullable signatureResult, NSError * _Nullable signatureError) {
        if (signatureResult != nil) {
            result(signatureResult);
        } else {
            result(signatureError);
        }
    }];
}

- (void)listAssociationKeys:(FlutterMethodCall*)call result:(FlutterResult)result {
    [self.keyri listAssociationKeysWithCompletion:^(NSDictionary<NSString *,NSString *> * _Nullable associationKeys, NSError * _Nullable error) {
        if (associationKeys != nil) {
            result(associationKeys);
        } else {
            result(error);
        }
    }];
}

- (void)listUniqueAccounts:(FlutterMethodCall*)call result:(FlutterResult)result {
    [self.keyri listUniqueAccountsWithCompletion:^(NSDictionary<NSString *,NSString *> * _Nullable associationKeys, NSError * _Nullable error) {
        if (associationKeys != nil) {
            result(associationKeys);
        } else {
            result(error);
        }
    }];
}

- (void)getAssociationKey:(FlutterMethodCall*)call result:(FlutterResult)result {
    id publicUserIdValue = call.arguments[@"publicUserId"];

    NSString *publicUserId = [publicUserIdValue isKindOfClass:[NSString class]] ? publicUserIdValue : nil;

    [self.keyri getAssociationKeyWithPublicUserId:publicUserId completion:^(NSString * _Nullable associationKey, NSError * _Nullable error) {
        if (associationKey != nil) {
            result(associationKey);
        } else {
            result(error);
        }
    }];
}

- (void)removeAssociationKey:(FlutterMethodCall*)call result:(FlutterResult)result {
    id publicUserIdValue = call.arguments[@"publicUserId"];

    NSString *publicUserId = [publicUserIdValue isKindOfClass:[NSString class]] ? publicUserIdValue : nil;

    if (publicUserId == nil || ![publicUserId isKindOfClass:[NSString class]]) {
        return result(@"You need to provide publicUserId");
    }

    [self.keyri removeAssociationKeyWithPublicUserId: publicUserId completion:^(NSError * _Nullable error) {
        if (error != nil) {
            result(error);
        }

        result(@(YES));
    }];
}

- (void)sendEvent:(FlutterMethodCall*)call result:(FlutterResult)result {
    // TODO: Process arguments (BOOL also)
    id publicUserId = call.arguments[@"publicUserId"];
    NSString *eventType = call.arguments[@"eventType"];
    id success = call.arguments[@"success"];

//    Boolean *success = [publicUserIdValue isKindOfClass:[NSString class]] ? publicUserIdValue : nil;

    if (![eventType isKindOfClass:[NSString class]]) {
        return result(@"You need to provide eventType");
    }

    __weak typeof (self) weakSelf = self;
    [self.keyri sendEventWithPublicUserId:publicUserId eventType:eventType success:success completion:^(FingerprintResponse * _Nullable fingerprintResponse, NSError * _Nullable error) {
        typeof (self) strongSelf = weakSelf;

        if (error != nil) {
            return result(error);
        }

        if (fingerprintResponse != nil) {
            NSDictionary *dict = [strongSelf dictionaryWithPropertiesOfObject:fingerprintResponse];
            result(dict);
        } else {
            result(@"Fingerprint response is null");
        }
    }];
}

- (void)initiateQrSession:(FlutterMethodCall*)call result:(FlutterResult)result {
    // TODO: Fix arguments
    NSData *sessionId = call.arguments[@"sessionId"];
    NSString *publicUserId = call.arguments[@"publicUserId"];

    if (sessionId == nil || ![sessionId isKindOfClass:[NSData class]]) {
        return result(@"You need to provide sessionId");
    }

    __weak typeof (self) weakSelf = self;
    [self.keyri initiateQrSessionWithSessionId:sessionId publicUserId:publicUserId completion:^(Session * _Nullable session, NSError * _Nullable error) {
        typeof (self) strongSelf = weakSelf;

        if (error != nil) {
            return result(error);
        }

        if (session != nil) {
            strongSelf.activeSession = session;
            NSDictionary *dict = [self dictionaryWithPropertiesOfObject:session];
            result(dict);
        } else {
            result(@"Session not found");
        }
    }];
}
// TODO: Uncomment when available
//- (void)login:(FlutterMethodCall*)call result:(FlutterResult)result {
//    id publicUserIdValue = call.arguments[@"publicUserId"];
//
//    NSString *publicUserId = [publicUserIdValue isKindOfClass:[NSString class]] ? publicUserIdValue : nil;
//
//    [self.keyri loginWithPublicUserId:publicUserId completion:^(NSString * _Nullable loginObject, NSError * _Nullable error) {
//        if (loginObject != nil) {
//            NSDictionary *dict = [self dictionaryWithPropertiesOfObject:loginObject];
//            result(dict);
//        } else {
//            result(error);
//        }
//    }];
//}
//
//- (void)register:(FlutterMethodCall*)call result:(FlutterResult)result {
//    id publicUserIdValue = call.arguments[@"publicUserId"];
//
//    NSString *publicUserId = [publicUserIdValue isKindOfClass:[NSString class]] ? publicUserIdValue : nil;
//
//    [self.keyri registerWithPublicUserId:publicUserId completion:^(NSString * _Nullable registerObject, NSError * _Nullable error) {
//        if (registerObject != nil) {
//            NSDictionary *dict = [self dictionaryWithPropertiesOfObject:registerObject];
//            result(dict);
//        } else {
//            result(error);
//        }
//    }];
//}

- (void)initializeDefaultConfirmationScreen:(FlutterMethodCall*)call result:(FlutterResult)result {
    // TODO: Fix arguments

    if (self.activeSession == nil) {
        return result(@"Session not found");
    }

    NSString *payload = call.arguments[@"payload"];

    if (payload == nil || ![payload isKindOfClass:[NSData class]]) {
        return result(@"You need to provide payload");
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.keyri initializeDefaultConfirmationScreenWithSession:self.activeSession payload:payload completion:^(BOOL isApproved, NSError * _Nullable error) {
            if (isApproved) {
                result(@(YES));
            } else {
                if (![error isEqual:nil]) {
                    if ([error.localizedDescription isEqualToString:@"Denied by user"]) {
                        // TODO: false or no?
                        result(@(false));
                    } else {
                        return result(error);
                    }
                }
            }
        }];
    });
}

- (void)processLink:(FlutterMethodCall*)call result:(FlutterResult)result {
    // TODO: Fix arguments
    id urlString = call.arguments[@"url"];
    id publicUserId = call.arguments[@"publicUserId"];
    id payload = call.arguments[@"payload"];

    if (![payload isKindOfClass:[NSString class]]) { return result(@"You need to provide payload"); }
    if (![publicUserId isKindOfClass:[NSString class]]) { return result(@"You need to provide publicUserId"); }
    if (![urlString isKindOfClass:[NSString class]]) { return result(@"You need to provide url"); }

    __weak typeof (self) weakSelf = self;
    [self.keyri processLinkWithUrl:[NSURL URLWithString:urlString] payload:payload publicUserId:publicUserId completion:^(BOOL success, NSError * _Nullable error) {
        typeof (self) strongSelf = weakSelf;
        if (error != nil) {
            return result(error);
        }

        result(@(success));
    }];
}

- (void)confirmSession:(FlutterMethodCall*)call result:(FlutterResult)result {
    // TODO: Fix arguments

    NSString *payload = call.arguments[@"payload"];
    NSString *trustNewBrowser = call.arguments[@"trustNewBrowser"];

    if (payload == nil || ![payload isKindOfClass:[NSString class]]) {
        return result(@"You need to provide payload");
    }

    [self finishSession:payload isApproved:YES trustNewBrowser:trustNewBrowser result:result];
}

- (void)denySession:(FlutterMethodCall*)call result:(FlutterResult)result {
    // TODO: Fix arguments

    NSString *payload = call.arguments[@"payload"];

    if (payload == nil || ![payload isKindOfClass:[NSString class]]) {
        return result(@"You need to provide payload");
    }

    [self finishSession:payload isApproved:NO trustNewBrowser:NO result:result];
}

- (void)finishSession:(NSString *)payload isApproved:(BOOL)isApproved trustNewBrowser:(BOOL)trustNewBrowser result:(FlutterResult)result {
    if (isApproved) {
        [self.activeSession confirmWithPayload:payload trustNewBrowser:trustNewBrowser completion:^(NSError * _Nullable error) {
            if (error == nil) {
                result(@(YES));
            } else {
                result(error);
            }
        }];
    } else {
        [self.activeSession denyWithPayload:payload completion:^(NSError * _Nullable error) {
            if (error == nil) {
                result(@(YES));
            } else {
                result(error);
            }
        }];
    }
}

- (NSDictionary *)dictionaryWithPropertiesOfObject:(id)object
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    unsigned count;
    objc_property_t *properties = class_copyPropertyList([object class], &count);

    for (int i = 0; i < count; i++) {
        NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
        id value = [object valueForKey:key];
        if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
            [dict setObject:value forKey:key];
        } else {
            id valueDict = [self dictionaryWithPropertiesOfObject:value];
            if (valueDict && [[valueDict allKeys] count] > 0) {
                [dict setObject:valueDict forKey:key];
            }
        }
    }

    free(properties);

    return [NSDictionary dictionaryWithDictionary:dict];
}

@end
