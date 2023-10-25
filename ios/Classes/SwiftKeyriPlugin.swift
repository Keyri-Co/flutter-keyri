import Flutter
import CryptoKit
import UIKit
import Keyri
import os

public class SwiftKeyriPlugin: NSObject, FlutterPlugin {
    var activeSession: Session?
    var keyri: KeyriInterface?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "keyri", binaryMessenger: registrar.messenger())
        let instance = SwiftKeyriPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            initialize(call, result: result)
        case "easyKeyriAuth":
            easyKeyriAuth(call, result: result)
        case "generateAssociationKey":
            generateAssociationKey(call, result: result)
        case "generateUserSignature":
            generateUserSignature(call, result: result)
        case "listAssociationKeys":
            listAssociationKeys(call, result: result)
        case "listUniqueAccounts":
            listUniqueAccounts(call, result: result)
        case "getAssociationKey":
            getAssociationKey(call, result: result)
        case "removeAssociationKey":
            removeAssociationKey(call, result: result)
        case "sendEvent":
            sendEvent(call, result: result)
        case "initiateQrSession":
            initiateQrSession(call, result: result)
        case "initializeDefaultConfirmationScreen":
            initializeDefaultConfirmationScreen(call, result: result)
        case "processLink":
            processLink(call, result: result)
        case "confirmSession":
            confirmSession(call, result: result)
        case "denySession":
            denySession(call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func initialize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        logMessage(message: "Keyri: initialize called")
        
        if let args = call.arguments as? [String: Any] {
            guard let appKey = args["appKey"] as? String else {
                errorArgumentsResult(argumentName: "appKey", result: result)
                return
            }
            
            let publicApiKey = args["publicApiKey"] as? String
            let serviceEncryptionKey = args["serviceEncryptionKey"] as? String
            let blockEmulatorDetection = args["blockEmulatorDetection"] as? String
            
            keyri = KeyriInterface(appKey: appKey, publicApiKey: publicApiKey, serviceEncryptionKey: serviceEncryptionKey, blockEmulatorDetection: Bool(blockEmulatorDetection ?? "true"))
            
            logMessage(message: "Keyri initialized")
            result(true)
        } else {
            errorArgumentsResult(argumentName: "call.arguments", result: result)
        }
    }
    
    private func easyKeyriAuth(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        logMessage(message: "Keyri: easyKeyriAuth called")
        
        if let args = call.arguments as? [String: Any] {
            guard let payload = args["payload"] as? String else {
                errorArgumentsResult(argumentName: "payload", result: result)
                return
            }
            
            let publicUserId = args["publicUserId"] as? String
            
            keyri?.easyKeyriAuth(payload: payload, publicUserId: publicUserId) { authResult in
                switch authResult {
                case .failure(let error):
                    self.errorResult(error: error, result: result)
                case .success(let boolResult):
                    self.logMessage(message: "Keyri: easyKeyriAuth: \(boolResult)")
                    result(boolResult)
                }
            }
        } else {
            errorArgumentsResult(argumentName: "call.arguments", result: result)
        }
    }
    
    private func generateAssociationKey(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        logMessage(message: "Keyri: generateAssociationKey called")
        
        if let args = call.arguments as? [String: Any] {
            let completion: (Result<P256.Signing.PublicKey, Error>) -> () = { keyResult in
                switch keyResult {
                case .success(let key):
                    self.logMessage(message: "Keyri: generateAssociationKey: \(key)")
                    result(key.derRepresentation.base64EncodedString())
                case .failure(let error):
                    self.errorResult(error: error, result: result)
                }
            }
            
            if let publicUserId = args["publicUserId"] as? String {
                keyri?.generateAssociationKey(publicUserId: publicUserId, completion: completion)
            } else {
                keyri?.generateAssociationKey(completion: completion)
            }
        } else {
            errorArgumentsResult(argumentName: "call.arguments", result: result)
        }
    }
    
    private func generateUserSignature(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        logMessage(message: "Keyri: generateUserSignature called")
        
        if let args = call.arguments as? [String: Any] {
            guard let dataString = args["data"] as? String,
                  let data = dataString.data(using: .utf8) else {
                errorArgumentsResult(argumentName: "data", result: result)
                return
            }
            
            let completion: (Result<P256.Signing.ECDSASignature, Error>) -> () = { signatureResult in
                switch signatureResult {
                case .success(let signature):
                    self.logMessage(message: "Keyri: generateUserSignature: \(signature)")
                    result(signature.derRepresentation.base64EncodedString())
                case .failure(let error):
                    self.errorResult(error: error, result: result)
                }
            }
            
            if let publicUserId = args["publicUserId"] as? String {
                keyri?.generateUserSignature(publicUserId: publicUserId, data: data, completion: completion)
            } else {
                keyri?.generateUserSignature(data: data, completion: completion)
            }
        } else {
            errorArgumentsResult(argumentName: "call.arguments", result: result)
        }
    }
    
    private func listAssociationKeys(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        logMessage(message: "Keyri: listAssociationKeys called")
        
        keyri?.listAssociationKeys { keysResult in
            switch keysResult {
            case.failure (let error):
                self.errorResult(error: error, result: result)
            case .success(let keys):
                self.logMessage(message: "Keyri: listAssociationKeys: \(String(describing: keys))")
                result(keys)
            }
        }
    }
    
    private func listUniqueAccounts(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        logMessage(message: "Keyri: listUniqueAccounts called")
        
        keyri?.listUniqueAccounts { keysResult in
            switch keysResult {
            case.failure (let error):
                self.errorResult(error: error, result: result)
            case .success(let keys):
                self.logMessage(message: "Keyri: listUniqueAccounts: \(String(describing: keys))")
                result(keys)
            }
        }
    }
    
    private func getAssociationKey(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        logMessage(message: "Keyri: getAssociationKey called")
        
        if let args = call.arguments as? [String: Any] {
            let completion: (Result<P256.Signing.PublicKey?, Error>) -> () = { keyResult in
                switch keyResult {
                case .success(let key):
                    self.logMessage(message: "Keyri: getAssociationKey: \(String(describing: key))")
                    result(key?.derRepresentation.base64EncodedString())
                case .failure(let error):
                    self.errorResult(error: error, result: result)
                }
            }
            
            if let publicUserId = args["publicUserId"] as? String {
                keyri?.getAssociationKey(publicUserId: publicUserId, completion: completion)
            } else {
                keyri?.getAssociationKey(completion: completion)
            }
        } else {
            errorArgumentsResult(argumentName: "call.arguments", result: result)
        }
    }
    
    private func removeAssociationKey(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        logMessage(message: "Keyri: removeAssociationKey called")
        
        if let args = call.arguments as? [String: Any] {
            guard let publicUserId = args["publicUserId"] as? String else {
                errorArgumentsResult(argumentName: "publicUserId", result: result)
                return
            }
            
            keyri?.removeAssociationKey(publicUserId: publicUserId) { removeResult in
                switch removeResult {
                case.failure (let error):
                    self.errorResult(error: error, result: result)
                case .success:
                    self.logMessage(message: "Keyri: removeAssociationKey succes")
                    result(true)
                }
            }
        } else {
            errorArgumentsResult(argumentName: "call.arguments", result: result)
        }
    }
    
    private func sendEvent(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        logMessage(message: "Keyri: sendEvent called")
        
        if let args = call.arguments as? [String: Any] {
            guard let eventTypeString = args["eventType"] as? String,
                  let eventType = EventType(rawValue: eventTypeString) else {
                errorArgumentsResult(argumentName: "eventType", result: result)
                return
            }
            
            guard let successString = args["success"] as? String,
                  let success = Bool(successString) else {
                errorArgumentsResult(argumentName: "success", result: result)
                return
            }
            
            let completion: (Result<FingerprintResponse, Error>) -> () = { fingerprintEventResult in
                switch fingerprintEventResult {
                case .success(let fingerprintEventResponse):
                    self.logMessage(message: "Keyri: sendEvent: \(String(describing: fingerprintEventResponse.asDictionary()))")
                    result(fingerprintEventResponse.asDictionary())
                    return
                case .failure(let error):
                    self.errorResult(error: error, result: result)
                    return
                }
            }
            
            if let publicUserId = args["publicUserId"] as? String {
                keyri?.sendEvent(publicUserId: publicUserId, eventType: eventType, success: success, completion: completion)
            } else {
                keyri?.sendEvent(eventType: eventType, success: success, completion: completion)
            }
        } else {
            errorArgumentsResult(argumentName: "call.arguments", result: result)
        }
    }
    
    private func initiateQrSession(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        logMessage(message: "Keyri: initiateQrSession called")
        
        if let args = call.arguments as? [String: Any] {
            guard let sessionId = args["sessionId"] as? String else {
                errorArgumentsResult(argumentName: "sessionId", result: result)
                return
            }
            
            let publicUserId = args["publicUserId"] as? String
            
            keyri?.initiateQrSession(sessionId: sessionId, publicUserId: publicUserId) { sessionResult in
                switch sessionResult {
                case .failure(let error):
                    self.errorResult(error: error, result: result)
                case .success(let session):
                    self.activeSession = session
                    
                    self.logMessage(message: "Keyri: initiateQrSession: \(String(describing: session.asDictionary()))")
                    result(session.asDictionary())
                }
            }
        } else {
            errorArgumentsResult(argumentName: "call.arguments", result: result)
        }
    }
    
    private func initializeDefaultConfirmationScreen(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        logMessage(message: "Keyri: initializeDefaultConfirmationScreen called")
        
        if let session = self.activeSession {
            if let args = call.arguments as? [String: Any] {
                guard let payload = args["payload"] as? String else {
                    errorArgumentsResult(argumentName: "payload", result: result)
                    return
                }
                
                keyri?.initializeDefaultConfirmationScreen(session: session, payload: payload) { boolResult in
                    self.logMessage(message: "Keyri: initializeDefaultConfirmationScreen: \(boolResult)")
                    result(boolResult)
                }
            } else {
                errorArgumentsResult(argumentName: "call.arguments", result: result)
            }
        } else {
            errorArgumentsResult(argumentName: "session", result: result)
        }
    }
    
    private func processLink(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        logMessage(message: "Keyri: processLink called")
        
        if let args = call.arguments as? [String: Any] {
            guard let linkString = args["link"] as? String,
                  let link = URL(string: linkString) else {
                errorArgumentsResult(argumentName: "link", result: result)
                return
            }
            
            guard let payload = args["payload"] as? String else {
                errorArgumentsResult(argumentName: "payload", result: result)
                return
            }
            
            let publicUserId = args["publicUserId"] as? String
            
            keyri?.processLink(url: link, payload: payload, publicUserId: publicUserId) { boolResult in
                self.logMessage(message: "Keyri: processLink: \(boolResult)")
                result(boolResult)
            }
        } else {
            errorArgumentsResult(argumentName: "call.arguments", result: result)
        }
    }
    
    private func confirmSession(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        logMessage(message: "Keyri: confirmSession called")
        
        if let args = call.arguments as? [String: Any] {
            guard let payload = args["payload"] as? String else {
                errorArgumentsResult(argumentName: "payload", result: result)
                return
            }
            
            guard let trustNewBrowserString = args["trustNewBrowser"] as? String,
                  let trustNewBrowser = Bool(trustNewBrowserString) else {
                errorArgumentsResult(argumentName: "trustNewBrowser", result: result)
                return
            }
            
            activeSession?.confirm(payload: payload, trustNewBrowser: trustNewBrowser) { sessionResult in
                switch sessionResult {
                case .some(let error):
                    self.errorResult(error: error, result: result)
                case .none:
                    self.logMessage(message: "Keyri: confirmSession success")
                    result(true)
                }
            }
        } else {
            errorArgumentsResult(argumentName: "call.arguments", result: result)
        }
    }
    
    private func denySession(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        logMessage(message: "Keyri: denySession called")
        
        if let args = call.arguments as? [String: Any] {
            guard let payload = args["payload"] as? String else {
                errorArgumentsResult(argumentName: "payload", result: result)
                return
            }
            
            activeSession?.deny(payload: payload) { sessionResult in
                switch sessionResult {
                case .some(let error):
                    self.errorResult(error: error, result: result)
                case .none:
                    self.logMessage(message: "Keyri: denySession success")
                    result(true)
                }
            }
        } else {
            errorArgumentsResult(argumentName: "call.arguments", result: result)
        }
    }
    
    private func errorArgumentsResult(argumentName: String, result: @escaping FlutterResult) {
        let errorMessage = "Failed to parse arguments: \(argumentName) shouldn't be nil"
        
        logMessage(message: errorMessage, type: OSLogType.error)
        result(FlutterError(code: "BAD_ARGUMENTS", message: errorMessage, details: nil))
    }
    
    private func errorResult(error: Error, result: @escaping FlutterResult) {
        logMessage(message: error.localizedDescription, type: OSLogType.error)
        result(FlutterError(code: "KEYRI_ERROR", message: error.localizedDescription, details: nil))
    }
    
    private func logMessage(message: String, type: OSLogType = .debug) {
#if DEBUG
        os_log("%@", log: .default, type: type, message)
#endif
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
