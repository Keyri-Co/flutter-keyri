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
        if call.method == "easyKeyriAuth" {
            if let args = call.arguments as? [String: String],
               let username = args["publicUserId"],
               let payload = args["payload"],
               let appKey = args["appKey"] {
                keyri.easyKeyriAuth(publicUserId: username, appKey: appKey, payload: payload) { didSucceed in
                    switch didSucceed {
                    case.failure:
                        result(false)
                    case .success(let bool):
                        result(bool)
                    }
                }
            }
        }
        
        if call.method == "initiateQrSession" {
            if let args = call.arguments as? [String: String],
               let username = args["publicUserId"],
               let sessionId = args["sessionId"],
               let appKey = args["appKey"] {
                keyri.initiateQrSession(username: username, sessionId: sessionId, appKey: appKey) { returnedSession in
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
        
        if call.method == "confirmSession" {
            if let args = call.arguments as? [String: String],
               let sessionId = args["sessionId"] {
                activeSession?.confirm()
                result(true)
            } else {
                result(false)
            }
        }
        
        if call.method == "denySession" {
            if let args = call.arguments as? [String: String],
               let sessionId = args["sessionId"] {
                activeSession?.deny()
                result(true)
            } else {
                result(false)
            }
        }
        
        if call.method == "initializeDefaultScreen" {
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
        
        if call.method == "getAssociationKey" {
            if let args = call.arguments as? [String: String],
               let user = args["publicUserId"] {
                do {
                    let key = try keyri.getAssociationKey(username:user)?.derRepresentation.base64EncodedString
                    result(key ?? "NULL")
                } catch {
                    result(error.localizedDescription)
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
