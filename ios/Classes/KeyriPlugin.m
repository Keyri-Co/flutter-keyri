#import "KeyriPlugin.h"
#import <objc/runtime.h>
@import Keyri;

@interface KeyriPlugin ()

@property (nonatomic, strong) KeyriObjC *keyri;
@property (nonatomic, strong) Session *activeSession;

@end

@implementation KeyriPlugin

+ (BOOL)requiresMainQueueSetup
{
    return NO;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:@"keyri" binaryMessenger:[registrar messenger]];
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
    } else if ([@"createFingerprint" isEqualToString:call.method]) {
        [self createFingerprint:call result:result];
    } else if ([@"initiateQrSession" isEqualToString:call.method]) {
        [self initiateQrSession:call result:result];
    } else if ([@"login" isEqualToString:call.method]) {
        [self login:call result:result];
    } else if ([@"register" isEqualToString:call.method]) {
        [self register:call result:result];
    } else if ([@"getCorrectedTimestampSeconds" isEqualToString:call.method]) {
        [self getCorrectedTimestampSeconds:call result:result];
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
    id blockEmulatorDetectionValue = call.arguments[@"blockEmulatorDetection"];
    // TODO: Uncomment and add implementation
//    id blockRootDetection = call.arguments[@"blockRootDetection"];
//    id blockDangerousAppsDetection = call.arguments[@"blockDangerousAppsDetection"];
//    id blockTamperDetection = call.arguments[@"blockTamperDetection"];
//    id blockSwizzleDetection = call.arguments[@"blockSwizzleDetection"];

    if (appKey == nil || ![appKey isKindOfClass:[NSString class]]) {
        return [self sendErrorResult:result errorMessage:@"You need to provide appKey"];
    }

    BOOL blockEmulatorDetection = YES;

    if (blockEmulatorDetectionValue != nil || [blockEmulatorDetectionValue isKindOfClass:[NSNumber class]]) {
        blockEmulatorDetection = [blockEmulatorDetectionValue boolValue];
    }

    NSString *publicApiKey = [publicApiKeyValue isKindOfClass:[NSString class]] ? publicApiKeyValue : nil;
    NSString *serviceEncryptionKey = [serviceEncryptionKeyValue isKindOfClass:[NSString class]] ? serviceEncryptionKeyValue : nil;

    // TODO: Add impl
//    KeyriDetectionsConfig *config = [[KeyriDetectionsConfig alloc] initWithBlockEmulatorDetection: blockEmulatorDetection blockRootDetection:blockRootDetection blockDangerousAppsDetection:blockDangerousAppsDetection blockTamperDetection:blockTamperDetection blockSwizzleDetection:blockSwizzleDetection];
//
//    self.keyri = [[KeyriObjC alloc] initWithAppKey:appKey publicApiKey:publicApiKey serviceEncryptionKey:serviceEncryptionKey detectionsConfig:config];

    [self.keyri initializeKeyriWithAppKey:appKey publicApiKey:publicApiKey serviceEncryptionKey:serviceEncryptionKey blockEmulatorDetection:blockEmulatorDetection];
    result(@(YES));
}

- (void)easyKeyriAuth:(FlutterMethodCall*)call result:(FlutterResult)result {
    id publicUserIdValue = call.arguments[@"publicUserId"];
    id payload = call.arguments[@"payload"];

    if (payload == nil || ![payload isKindOfClass:[NSString class]]) {
        return [self sendErrorResult:result errorMessage:@"You need to provide payload"];
    }

    NSString *publicUserId = [publicUserIdValue isKindOfClass:[NSString class]] ? publicUserIdValue : nil;

    dispatch_async(dispatch_get_main_queue(), ^{
        __weak typeof (self) weakSelf = self;
        [self.keyri easyKeyriAuthWithPayload:payload publicUserId:publicUserId completion:^(BOOL success, NSError * _Nullable error) {
            typeof (self) strongSelf = weakSelf;

            return [self sendResult:result forObject:@(success) error:error];
        }];
    });
}

- (void)generateAssociationKey:(FlutterMethodCall*)call result:(FlutterResult)result {
    id publicUserIdValue = call.arguments[@"publicUserId"];

    NSString *publicUserId = [publicUserIdValue isKindOfClass:[NSString class]] ? publicUserIdValue : nil;

    [self.keyri generateAssociationKeyWithPublicUserId:publicUserId completion:^(NSString * _Nullable generatedKey, NSError * _Nullable error) {
        return [self sendResult:result forObject:generatedKey error:error];
    }];
}

- (void)generateUserSignature:(FlutterMethodCall*)call result:(FlutterResult)result {
    id dataValue = call.arguments[@"data"];
    id publicUserIdValue = call.arguments[@"publicUserId"];

    if (![dataValue isKindOfClass:[NSString class]]) {
        return [self sendErrorResult:result errorMessage:@"You need to provide valid data as a string"];
    }

    NSString *dataString = (NSString *)dataValue;
    NSData *dataToSign = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *publicUserId = [publicUserIdValue isKindOfClass:[NSString class]] ? publicUserIdValue : nil;

    if (dataToSign == nil) {
        return [self sendErrorResult:result errorMessage:@"Failed to convert data to NSData"];
    }

    [self.keyri generateUserSignatureWithPublicUserId:publicUserId data:dataToSign completion:^(NSString * _Nullable signatureResult, NSError * _Nullable signatureError) {
        return [self sendResult:result forObject:signatureResult error:signatureError];
    }];
}

- (void)listAssociationKeys:(FlutterMethodCall*)call result:(FlutterResult)result {
    [self.keyri listAssociationKeysWithCompletion:^(NSDictionary<NSString *,NSString *> * _Nullable associationKeys, NSError * _Nullable error) {
        return [self sendResult:result forObject:associationKeys error:error];
    }];
}

- (void)listUniqueAccounts:(FlutterMethodCall*)call result:(FlutterResult)result {
    [self.keyri listUniqueAccountsWithCompletion:^(NSDictionary<NSString *,NSString *> * _Nullable associationKeys, NSError * _Nullable error) {
        return [self sendResult:result forObject:associationKeys error:error];
    }];
}

- (void)getAssociationKey:(FlutterMethodCall*)call result:(FlutterResult)result {
    id publicUserIdValue = call.arguments[@"publicUserId"];

    NSString *publicUserId = [publicUserIdValue isKindOfClass:[NSString class]] ? publicUserIdValue : nil;

    [self.keyri getAssociationKeyWithPublicUserId:publicUserId completion:^(NSString * _Nullable associationKey, NSError * _Nullable error) {
        return [self sendResult:result forObject:associationKey error:error];
    }];
}

- (void)removeAssociationKey:(FlutterMethodCall*)call result:(FlutterResult)result {
    id publicUserIdValue = call.arguments[@"publicUserId"];

    NSString *publicUserId = [publicUserIdValue isKindOfClass:[NSString class]] ? publicUserIdValue : nil;

    if (publicUserId == nil || ![publicUserId isKindOfClass:[NSString class]]) {
        return [self sendErrorResult:result errorMessage:@"You need to provide publicUserId"];
    }

    [self.keyri removeAssociationKeyWithPublicUserId: publicUserId completion:^(NSError * _Nullable error) {
        return [self sendResult:result forObject:@(YES) error:error];
    }];
}

- (void)sendEvent:(FlutterMethodCall*)call result:(FlutterResult)result {
    id publicUserIdValue = call.arguments[@"publicUserId"];
    id eventType = call.arguments[@"eventType"];
    id metadata = call.arguments[@"metadata"];
    id successValue = call.arguments[@"success"];

    NSString *publicUserId = [publicUserIdValue isKindOfClass:[NSString class]] ? publicUserIdValue : nil;

    BOOL success = NO;

    if (successValue != nil || [successValue isKindOfClass:[NSNumber class]]) {
        success = [successValue boolValue];
    } else {
        return [self sendErrorResult:result errorMessage:@"You need to provide success"];
    }

    if (eventType == nil || ![eventType isKindOfClass:[NSString class]]) {
        return [self sendErrorResult:result errorMessage:@"You need to provide eventType"];
    }

    NSData *jsonData = [metadata dataUsingEncoding:NSUTF8StringEncoding];

    NSError *error = nil;
    NSDictionary *metadataDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];

    EventType *event = [EventType customWithName:eventType metadata:metadataDictionary];

    __weak typeof (self) weakSelf = self;
    [self.keyri sendEventWithPublicUserId:publicUserId eventType:event success:success completion:^(FingerprintResponse * _Nullable fingerprintResponse, NSError * _Nullable error) {
        typeof (self) strongSelf = weakSelf;

        if (error != nil) {
            return result([FlutterError errorWithCode:@"1" message:error.localizedDescription details:nil]);
        }

        if (fingerprintResponse != nil) {
            return result([strongSelf dictionaryWithPropertiesOfObject:fingerprintResponse]);
        } else {
            return [self sendErrorResult:result errorMessage:@"Fingerprint response is null"];
        }
    }];
}

- (void)createFingerprint:(FlutterMethodCall*)call result:(FlutterResult)result {
    [self.keyri createFingerprintWithCompletion:^(FingerprintRequest * _Nullable fingerprint, NSError * _Nullable error) {
        if (error != nil) {
            return result([FlutterError errorWithCode:@"1" message:error.localizedDescription details:nil]);
        }

        if (fingerprint != nil) {
            return result([self dictionaryWithPropertiesOfObject:fingerprint]);
        } else {
            return [self sendErrorResult:result errorMessage:@"FingerprintRequest is nil"];
        }
    }];
}

- (void)initiateQrSession:(FlutterMethodCall*)call result:(FlutterResult)result {
    id sessionId = call.arguments[@"sessionId"];
    id publicUserIdValue = call.arguments[@"publicUserId"];

    if (sessionId == nil || ![sessionId isKindOfClass:[NSString class]]) {
        return [self sendErrorResult:result errorMessage:@"You need to provide sessionId"];
    }

    NSString *publicUserId = [publicUserIdValue isKindOfClass:[NSString class]] ? publicUserIdValue : nil;

    __weak typeof (self) weakSelf = self;
    [self.keyri initiateQrSessionWithSessionId:sessionId publicUserId:publicUserId completion:^(Session * _Nullable session, NSError * _Nullable error) {
        typeof (self) strongSelf = weakSelf;

        if (error != nil) {
            return result([FlutterError errorWithCode:@"1" message:error.localizedDescription details:nil]);
        }

        if (session != nil) {
            strongSelf.activeSession = session;
            return result([self dictionaryWithPropertiesOfObject:session]);
        } else {
            return [self sendErrorResult:result errorMessage:@"Session not found"];
        }
    }];
}

- (void)login:(FlutterMethodCall*)call result:(FlutterResult)result {
    id publicUserIdValue = call.arguments[@"publicUserId"];

    NSString *publicUserId = [publicUserIdValue isKindOfClass:[NSString class]] ? publicUserIdValue : nil;

    [self.keyri loginWithPublicUserId:publicUserId completion:^(LoginObject * _Nullable loginObject, NSError * _Nullable error) {
        if (error != nil) {
            return result([FlutterError errorWithCode:@"1" message:error.localizedDescription details:nil]);
        }

        if (loginObject != nil) {
            return result([self dictionaryWithPropertiesOfObject:loginObject]);
        } else {
            return [self sendErrorResult:result errorMessage:@"LoginObject is nil"];
        }
    }];
}

- (void)register:(FlutterMethodCall*)call result:(FlutterResult)result {
    id publicUserIdValue = call.arguments[@"publicUserId"];

    NSString *publicUserId = [publicUserIdValue isKindOfClass:[NSString class]] ? publicUserIdValue : nil;

    [self.keyri registerWithPublicUserId:publicUserId completion:^(RegisterObject * _Nullable registerObject, NSError * _Nullable error) {
        if (error != nil) {
            return result([FlutterError errorWithCode:@"1" message:error.localizedDescription details:nil]);
        }

        if (registerObject != nil) {
            return result([self dictionaryWithPropertiesOfObject:registerObject]);
        } else {
            return [self sendErrorResult:result errorMessage:@"RegisterObject is nil"];
        }
    }];
}

- (void)getCorrectedTimestampSeconds:(FlutterMethodCall*)call result:(FlutterResult)result {
    [self.keyri getCorrectedTimestampSecondsWithCompletion:^(NSInteger timestamp) {
        return result(@(timestamp));
    }];
}

- (void)initializeDefaultConfirmationScreen:(FlutterMethodCall*)call result:(FlutterResult)result {
    id payload = call.arguments[@"payload"];

    if (payload == nil || ![payload isKindOfClass:[NSString class]]) {
        return [self sendErrorResult:result errorMessage:@"You need to provide payload"];
    }

    if (self.activeSession == nil) {
        return [self sendErrorResult:result errorMessage:@"Session not found"];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.keyri initializeDefaultConfirmationScreenWithSession:self.activeSession payload:payload completion:^(BOOL isApproved, NSError * _Nullable error) {
            if (isApproved) {
                return result(@(YES));
            } else {
                if (![error isEqual:nil]) {
                    if ([error.localizedDescription isEqualToString:@"Denied by user"]) {
                        return result(@(NO));
                    } else {
                        result(error);
                    }
                }
            }
        }];
    });
}

- (void)processLink:(FlutterMethodCall*)call result:(FlutterResult)result {
    id urlString = call.arguments[@"url"];
    id publicUserIdValue = call.arguments[@"publicUserId"];
    id payload = call.arguments[@"payload"];

    NSString *publicUserId = [publicUserIdValue isKindOfClass:[NSString class]] ? publicUserIdValue : nil;

    if (payload == nil || ![payload isKindOfClass:[NSString class]]) { return result(@"You need to provide payload"); }
    if (urlString == nil || ![urlString isKindOfClass:[NSString class]]) { return result(@"You need to provide url"); }

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
    id payload = call.arguments[@"payload"];
    id trustNewBrowserValue = call.arguments[@"trustNewBrowser"];

    if (payload == nil || ![payload isKindOfClass:[NSString class]]) {
        return result(@"You need to provide payload");
    }

    BOOL trustNewBrowser = NO;

    if (trustNewBrowserValue != nil || [trustNewBrowserValue isKindOfClass:[NSNumber class]]) {
        trustNewBrowser = [trustNewBrowserValue boolValue];
    } else {
        return result(@"You need to provide trustNewBrowser");
    }

    [self finishSession:payload isApproved:YES trustNewBrowser:trustNewBrowser result:result];
}

- (void)denySession:(FlutterMethodCall*)call result:(FlutterResult)result {
    id payload = call.arguments[@"payload"];

    if (payload == nil || ![payload isKindOfClass:[NSString class]]) {
        return result(@"You need to provide payload");
    }

    [self finishSession:payload isApproved:NO trustNewBrowser:NO result:result];
}

- (void)finishSession:(NSString *)payload isApproved:(BOOL)isApproved trustNewBrowser:(BOOL)trustNewBrowser result:(FlutterResult)result {
    if (isApproved) {
        [self.activeSession confirmWithPayload:payload trustNewBrowser:trustNewBrowser completion:^(NSError * _Nullable error) {
            return [self sendResult:result forObject:@(YES) error:error];
        }];
    } else {
        [self.activeSession denyWithPayload:payload completion:^(NSError * _Nullable error) {
            return [self sendResult:result forObject:@(YES) error:error];
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

- (void)sendResult:(FlutterResult)result forObject:(NSObject *)object error:(NSError *)error {
    if (error != nil) {
        result([FlutterError errorWithCode:@"1" message:error.localizedDescription details:nil]);
    } else if (object == nil) {
        result(nil);
    } else {
        result(object);
    }
}

- (void)sendResult:(FlutterResult)result forObject:(NSObject *)object errorMessage:(NSString *)errorMessage {
    if (errorMessage != nil) {
        result([FlutterError errorWithCode:@"1" message:errorMessage details:nil]);
    } else if (object == nil) {
        result(nil);
    } else {
        result(object);
    }
}

- (void)sendErrorResult:(FlutterResult)result errorMessage:(NSString *)errorMessage {
    result([FlutterError errorWithCode:@"1" message:errorMessage details:nil]);
}

@end
