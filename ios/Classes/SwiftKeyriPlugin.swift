import Flutter
import UIKit
import keyri_pod

public class SwiftKeyriPlugin: NSObject, FlutterPlugin {
    var activeSession: Session?
    let keyri = Keyri()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "keyri", binaryMessenger: registrar.messenger())
        let instance = SwiftKeyriPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
            if call.method == "initialize" {
            // TODO initialize Keyri object
                if let args = call.arguments as? [String: String],
                   let appKey = args["appKey"],
                   let publicApiKey = args["publicApiKey"],
                   let serviceEncryptionKey = args["serviceEncryptionKey"],
//                    let blockEmulatorDetection = args["blockEmulatorDetection"] // TODO as Bool {
//                    let blockEmulatorDetection = args["blockEmulatorDetection"] {
//                     keyri.easyKeyriAuth(publicUserId: username, appKey: appKey, payload: payload) { didSucceed in
//                         switch didSucceed {
//                         case.failure:
//                             result(false)
//                         case .success(let bool):
//                             result(bool)
//                         }
//                     }
//                 }
            }

        if call.method == "easyKeyriAuth" {
            if let args = call.arguments as? [String: String],
               let appKey = args["appKey"],
               let publicApiKey = args["publicApiKey"],
               let serviceEncryptionKey = args["serviceEncryptionKey"],
               let blockEmulatorDetection = args["blockEmulatorDetection"], // TODO As Bool
               let payload = args["payload"],
               let publicUserId = args["publicUserId"] {
                keyri.easyKeyriAuth(
                    appKey: appKey,
                    publicApiKey: publicApiKey,
                    serviceEncryptionKey: serviceEncryptionKey,
                    blockEmulatorDetection: blockEmulatorDetection,
                    payload: payload,
                    publicUserId: publicUserId) { didSucceed in
                    switch didSucceed {
                    case.failure:
                        result(false)
                    case .success(let bool):
                        result(bool)
                    }
                }
            }
        }

        if call.method == "generateAssociationKey" {
            if let args = call.arguments as? [String: String],
               let user = args["publicUserId"] {
                do {
                    let key = try keyri.generateAssociationKey(username:user).derRepresentation.base64EncodedString
                    result(key)
                } catch {
                    result(error.localizedDescription)
                }
            }
        }

        if call.method == "generateUserSignature" {
            if let args = call.arguments as? [String: String],
               let user = args["publicUserId"],
               let data = args["data"] {
                do {
                    let key = try keyri.generateUserSignature(username:user, data:data).derRepresentation.base64EncodedString
                    result(key)
                } catch {
                    result(error.localizedDescription)
                }
            }
        }

        if call.method == "listAssociationKeys" {
            do {
            // TODO Add mapping
                let keys = try keyri.listAssociationKeys().derRepresentation.base64EncodedString
                result(keys)
            } catch {
                result(error.localizedDescription)
            }
        }

        if call.method == "listUniqueAccounts" {
            do {
            // TODO Add mapping
                let keys = try keyri.listUniqueAccounts().derRepresentation.base64EncodedString
                result(keys)
            } catch {
                result(error.localizedDescription)
            }
        }

        if call.method == "getAssociationKey" {
            if let args = call.arguments as? [String: String],
               let user = args["publicUserId"] {
                do {
                    let key = try keyri.getAssociationKey(username:user).derRepresentation.base64EncodedString
                    result(key)
                } catch {
                    result(error.localizedDescription)
                }
            }
        }

        if call.method == "removeAssociationKey" {
            do {
                try keyri.removeAssociationKey()
                result(true)
            } catch {
                result(error.localizedDescription)
            }
        }

        if call.method == "sendEvent" {
            if let args = call.arguments as? [String: String],
               let publicUserId = args["publicUserId"],
               let eventType = args["eventType"],
               let success = args["success"] { // TODO as Boolean
                keyri.initiateQrSession(publicUserId: publicUserId, eventType: eventType, success: success) { eventResponse in
                    switch eventResponse {
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
               let publicUserId = args["publicUserId"],
               let sessionId = args["sessionId"] {
                keyri.initiateQrSession(sessionId: sessionId, publicUserId: publicUserId) { returnedSession in
                    switch returnedSession {
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
                keyri.initializeDefaultConfirmationScreen(session: session, payload: payload) { bool in
                    result(bool)
                }
            } else {
                result(false)
            }
        }

        if call.method == "processLink" {
            if let args = call.arguments as? [String: String],
               let link = args["link"],
               let payload = args["payload"],
               let publicUserId = args["publicUserId"] {
                keyri.processLink(link: link, payload: payload, publicUserId: publicUserId) { bool in
                    result(bool)
                }
            } else {
                result(false)
            }
        }

        if call.method == "confirmSession" {
            if let args = call.arguments as? [String: String],
               let payload = args["payload"],
               let trustNewBrowser = args["trustNewBrowser"] { // TODO As Boolean
                activeSession?.confirm(payload, trustNewBrowser)
                result(true)
            } else {
                result(false)
            }
        }
        
        if call.method == "denySession" {
            if let args = call.arguments as? [String: String],
               let payload = args["payload"] { // TODO As Boolean
                activeSession?.deny(payload)
                result(true)
            } else {
                result(false)
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
