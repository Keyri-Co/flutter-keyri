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
            if let args = call.arguments as? [String: String],
               let appKey = args["appKey"],
               let publicApiKey = args["publicApiKey"],
               let serviceEncryptionKey = args["serviceEncryptionKey"],
               let blockEmulatorDetection = args["blockEmulatorDetection"] {
                keyri = KeyriInterface(appKey: appKey, publicApiKey: publicApiKey, serviceEncryptionKey: serviceEncryptionKey, blockEmulatorDetection: Bool(blockEmulatorDetection))
            } else {
                result("failed to parse arguments")
            }
        }
        
        if call.method == "easyKeyriAuth" {
            if let args = call.arguments as? [String: String],
               let payload = args["payload"],
               let publicUserId = args["publicUserId"] {
                keyri?.easyKeyriAuth(
                    payload: payload,
                    publicUserId: publicUserId) { authResult in
                        switch authResult {
                        case.failure (let error):
                            result(error.localizedDescription)
                        case .success(let boolResult):
                            result(boolResult)
                        }
                    }
            } else {
                result("failed to parse arguments")
            }
        }
        
        if call.method == "generateAssociationKey" {
            if let args = call.arguments as? [String: String],
               let publicUserId = args["publicUserId"] {
                keyri?.generateAssociationKey(publicUserId:publicUserId) { keyResult in
                    switch keyResult {
                    case.failure (let error):
                        result(error.localizedDescription)
                    case .success(let key):
                        result(key.derRepresentation.base64EncodedString)
                    }
                }
            } else {
                result("failed to parse arguments")
            }
        }
        
        if call.method == "generateUserSignature" {
            if let args = call.arguments as? [String: String],
               let publicUserId = args["publicUserId"],
               let dataString = args["data"],
               let data = dataString.data(using: .utf8) {
                keyri?.generateUserSignature(publicUserId:publicUserId, data:data) { signatureResult in
                    switch signatureResult {
                    case.failure (let error):
                        result(error.localizedDescription)
                    case .success(let signature):
                        result(signature.derRepresentation.base64EncodedString)
                    }
                }
            } else {
                result("failed to parse arguments")
            }
        }
        
        if call.method == "listAssociationKeys" {
            keyri?.listAssociactionKeys { keysResult in
                switch keysResult {
                case.failure (let error):
                    result(error.localizedDescription)
                case .success(let keys):
                    result(keys)
                }
            }
        }
        
        if call.method == "listUniqueAccounts" {
            keyri?.listUniqueAccounts { keysResult in
                switch keysResult {
                case.failure (let error):
                    result(error.localizedDescription)
                case .success(let keys):
                    result(keys)
                }
            }
        }
        
        if call.method == "getAssociationKey" {
            if let args = call.arguments as? [String: String],
               let publicUserId = args["publicUserId"] {
                keyri?.getAssociationKey(publicUserId:publicUserId) { keyResult in
                    switch keyResult {
                    case.failure (let error):
                        result(error.localizedDescription)
                    case .success(let key):
                        result(key?.derRepresentation.base64EncodedString)
                    }
                }
            } else {
                result("failed to parse arguments")
            }
        }
        
        if call.method == "removeAssociationKey" {
            if let args = call.arguments as? [String: String],
               let publicUserId = args["publicUserId"] {
                keyri?.removeAssociationKey(publicUserId: publicUserId) { removeResult in
                    switch removeResult {
                    case.failure (let error):
                        result(error.localizedDescription)
                    case .success:
                        result(true)
                    }
                }
            } else {
                result("failed to parse arguments")
            }
        }
        
        if call.method == "sendEvent" {
            if let args = call.arguments as? [String: String],
               let publicUserId = args["publicUserId"],
               let eventType = args["eventType"],
               let success = args["success"] {
                keyri?.sendEvent(publicUserId: publicUserId, eventType: EventType(rawValue: eventType) ?? .visits, success: Bool(success) ?? true) { sessionResult in
                    switch sessionResult {
                    case .failure(let error):
                        result(error.localizedDescription)
                    case .success(let fingerprintEventResponse):
                        result(fingerprintEventResponse.asDictionary())
                    }
                }
            } else {
                result("failed to parse arguments")
            }
        }
        
        if call.method == "initiateQrSession" {
            if let args = call.arguments as? [String: String],
               let sessionId = args["sessionId"],
               let publicUserId = args["publicUserId"] {
                keyri?.initiateQrSession(sessionId: sessionId, publicUserId: publicUserId) { sessionResult in
                    switch sessionResult {
                    case .failure(let error):
                        result(error.localizedDescription)
                    case .success(let session):
                        self.activeSession = session
                        result(session.asDictionary())
                    }
                }
            } else {
                result("failed to parse arguments")
            }
        }
        
        if call.method == "initializeDefaultConfirmationScreen" {
            if let session = self.activeSession,
               let args = call.arguments as? [String: String],
               let payload = args["payload"] {
                keyri?.initializeDefaultConfirmationScreen(session: session, payload: payload) { boolResult in
                    result(boolResult)
                }
            } else {
                result("failed to parse arguments")
            }
        }
        
        if call.method == "processLink" {
            if let args = call.arguments as? [String: String],
               let linkString = args["link"],
               let link = URL(string: linkString),
               let payload = args["payload"],
               let publicUserId = args["publicUserId"] {
                keyri?.processLink(url: link, payload: payload, publicUserId: publicUserId) { boolResult in
                    result(boolResult)
                }
            } else {
                result("failed to parse arguments")
            }
        }
        
        if call.method == "confirmSession" {
            if let args = call.arguments as? [String: String],
               let payload = args["payload"] {
                activeSession?.payload = payload
                
                activeSession?.confirm { sessionResult in
                    switch sessionResult {
                    case .some(let error):
                        result(error.localizedDescription)
                    case .none:
                        result(true)
                    }
                }
            } else {
                result("failed to parse arguments")
            }
        }
        
        if call.method == "denySession" {
            if let args = call.arguments as? [String: String],
               let payload = args["payload"] {
                activeSession?.payload = payload
                
                activeSession?.deny { sessionResult in
                    switch sessionResult {
                    case .some(let error):
                        result(error.localizedDescription)
                    case .none:
                        result(true)
                    }
                }
            } else {
                result("failed to parse arguments")
            }
        }
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
