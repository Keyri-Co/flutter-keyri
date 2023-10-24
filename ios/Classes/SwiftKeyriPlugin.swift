import Flutter
import UIKit
import Keyri

public class SwiftKeyriPlugin: NSObject, FlutterPlugin {
    var activeSession: Session?
    var keyri: KeyriInterface?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "keyri", binaryMessenger: registrar.messenger())
        let instance = SwiftKeyriPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "initialize" {
            if let args = call.arguments as? [String: Any],
               let appKey = args["appKey"] as? String,
               let blockEmulatorDetection = args["blockEmulatorDetection"] as? String {
                keyri = KeyriInterface(appKey: appKey, publicApiKey: args["publicApiKey"] as? String, serviceEncryptionKey: args["serviceEncryptionKey"] as? String, blockEmulatorDetection: Bool(blockEmulatorDetection))
                
                result(true)
            } else {
                errorArgumentsResult(result: result)
            }
        }
        
        if call.method == "easyKeyriAuth" {
            if let args = call.arguments as? [String: Any],
               let payload = args["payload"] as? String {
                keyri?.easyKeyriAuth(
                    payload: payload,
                    publicUserId: args["publicUserId"] as? String) { authResult in
                        switch authResult {
                        case.failure (let error):
                            self.errorResult(error: error, result: result)
                        case .success(let boolResult):
                            result(boolResult)
                        }
                    }
            } else {
                errorArgumentsResult(result: result)
            }
        }
        
        if call.method == "generateAssociationKey" {
            if let args = call.arguments as? [String: Any],
               let publicUserId = args["publicUserId"] as? String {
                keyri?.generateAssociationKey(publicUserId:publicUserId) { keyResult in
                    switch keyResult {
                    case.failure (let error):
                        self.errorResult(error: error, result: result)
                    case .success(let key):
                        result(key.derRepresentation.base64EncodedString)
                    }
                }
            } else {
                errorArgumentsResult(result: result)
            }
        }
        
        if call.method == "generateUserSignature" {
            if let args = call.arguments as? [String: Any],
               let publicUserId = args["publicUserId"] as? String,
               let dataString = args["data"] as? String,
               let data = dataString.data(using: .utf8) {
                keyri?.generateUserSignature(publicUserId:publicUserId, data:data) { signatureResult in
                    switch signatureResult {
                    case.failure (let error):
                        self.errorResult(error: error, result: result)
                    case .success(let signature):
                        result(signature.derRepresentation.base64EncodedString)
                    }
                }
            } else {
                errorArgumentsResult(result: result)
            }
        }
        
        if call.method == "listAssociationKeys" {
            keyri?.listAssociationKeys { keysResult in
                switch keysResult {
                case.failure (let error):
                    self.errorResult(error: error, result: result)
                case .success(let keys):
                    result(keys)
                }
            }
        }
        
        if call.method == "listUniqueAccounts" {
            keyri?.listUniqueAccounts { keysResult in
                switch keysResult {
                case.failure (let error):
                    self.errorResult(error: error, result: result)
                case .success(let keys):
                    result(keys)
                }
            }
        }
        
        if call.method == "getAssociationKey" {
            if let args = call.arguments as? [String: Any],
               let publicUserId = args["publicUserId"] as? String {
                keyri?.getAssociationKey(publicUserId:publicUserId) { keyResult in
                    switch keyResult {
                    case.failure (let error):
                        self.errorResult(error: error, result: result)
                    case .success(let key):
                        result(key?.derRepresentation.base64EncodedString)
                    }
                }
            } else {
                errorArgumentsResult(result: result)
            }
        }
        
        if call.method == "removeAssociationKey" {
            if let args = call.arguments as? [String: Any],
               let publicUserId = args["publicUserId"] as? String {
                keyri?.removeAssociationKey(publicUserId: publicUserId) { removeResult in
                    switch removeResult {
                    case.failure (let error):
                        self.errorResult(error: error, result: result)
                    case .success:
                        result(true)
                    }
                }
            } else {
                errorArgumentsResult(result: result)
            }
        }
        
        if call.method == "sendEvent" {
            if let args = call.arguments as? [String: Any],
               let eventType = args["eventType"] as? String,
               let success = args["success"] as? String {
               // TODO: Refactor as default arg
               keyri?.sendEvent(publicUserId: args["publicUserId"] as? String ?? "ANON", eventType: EventType(rawValue: eventType) ?? .visits, success: Bool(success) ?? true) { sessionResult in
                   switch sessionResult {
                   case .failure(let error):
                       self.errorResult(error: error, result: result)
                   case .success(let fingerprintEventResponse):
                       result(fingerprintEventResponse.asDictionary())
                   }
               }
            } else {
                errorArgumentsResult(result: result)
            }
        }
        
        if call.method == "initiateQrSession" {
            if let args = call.arguments as? [String: Any],
               let sessionId = args["sessionId"] as? String,
               let publicUserId = args["publicUserId"] as? String {
                keyri?.initiateQrSession(sessionId: sessionId, publicUserId: publicUserId) { sessionResult in
                    switch sessionResult {
                    case .failure(let error):
                        self.errorResult(error: error, result: result)
                    case .success(let session):
                        self.activeSession = session
                        result(session.asDictionary())
                    }
                }
            } else {
                errorArgumentsResult(result: result)
            }
        }
        
        if call.method == "initializeDefaultConfirmationScreen" {
            if let session = self.activeSession,
               let args = call.arguments as? [String: Any],
               let payload = args["payload"] as? String {
                keyri?.initializeDefaultConfirmationScreen(session: session, payload: payload) { boolResult in
                    result(boolResult)
                }
            } else {
                errorArgumentsResult(result: result)
            }
        }
        
        if call.method == "processLink" {
            if let args = call.arguments as? [String: Any],
               let linkString = args["link"] as? String,
               let link = URL(string: linkString),
               let payload = args["payload"] as? String,
               let publicUserId = args["publicUserId"] as? String {
                keyri?.processLink(url: link, payload: payload, publicUserId: publicUserId) { boolResult in
                    result(boolResult)
                }
            } else {
                errorArgumentsResult(result: result)
            }
        }
        
        if call.method == "confirmSession" {
            if let args = call.arguments as? [String: Any],
               let payload = args["payload"] as? String,
               let trustNewBrowser = args["trustNewBrowser"] as? String {
                activeSession?.confirm(payload: payload, trustNewBrowser: Bool(trustNewBrowser) ?? false) { sessionResult in
                    switch sessionResult {
                    case .some(let error):
                        self.errorResult(error: error, result: result)
                    case .none:
                        result(true)
                    }
                }
            } else {
                errorArgumentsResult(result: result)
            }
        }
        
        if call.method == "denySession" {
            if let args = call.arguments as? [String: Any],
               let payload = args["payload"] as? String {
                activeSession?.deny(payload: payload) { sessionResult in
                    switch sessionResult {
                    case .some(let error):
                        self.errorResult(error: error, result: result)
                    case .none:
                        result(true)
                    }
                }
            } else {
                errorArgumentsResult(result: result)
            }
        }
        
        result(FlutterMethodNotImplemented)
    }
    
    private func errorArgumentsResult(result: @escaping FlutterResult) {
        result(FlutterError(code: "BAD_ARGUMENTS", message: "Failed to parse arguments", details: nil))
    }
    
    private func errorResult(error: Error, result: @escaping FlutterResult) {
        result(FlutterError(code: "KEYRI_ERROR", message: error.localizedDescription, details: nil))
    }
}

extension Encodable {
    func asDictionary() -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else {
            return nil
        }
        guard let dictionary = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            return nil
        }
        return dictionary
    }
}
