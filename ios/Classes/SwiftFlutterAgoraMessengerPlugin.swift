import Flutter
import UIKit
import AgoraRtmKit
//import Toast_Swift

/**
 flutter回调方法：
 localInvitationAccept
 localInvitationRefused
 remoteInvitationReceived
 remoteInvitationCanceled
 */
public class SwiftFlutterAgoraMessengerPlugin: NSObject, FlutterPlugin {

//    private lazy var appleCallKit = CallCenter(delegate: self)
//    private var localNumber: String?
    private var methodChannel: FlutterMethodChannel
    
    init(channel: FlutterMethodChannel) {
        methodChannel = channel
        super.init()
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_agora_messenger", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterAgoraMessengerPlugin(channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "initial":
        if let args = call.arguments as? Dictionary<String, Any?>,
           let appId = args["appId"] as? String {
            print("initial appid: \(appId)")
            AgoraRtm.appId = appId
            let rtm = AgoraRtm.shared()
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/rtm.log"
            rtm.setLogPath(path)
            rtm.inviterDelegate = self
        }
    case "login":
        if let args = call.arguments as? Dictionary<String, Any?>,
           let account = args["account"] as? String,
           let token = args["token"] as? String {
            print("account: \(account), token: \(token)")
            login(account: account, token: token, result: result)
        } else {
            result("param error")
        }
    case "logout":
        logout(result: result)
    case "startOutgoingCall":
        if let args = call.arguments as? Dictionary<String, Any?>,
           let number = args["phoneNumber"] as? String {
            startOutgoingCall(remoteNumber: number, result: result)
        } else {
            result("param error")
        }
    case "hungUp":
        // 挂断本地呼叫
        if let args = call.arguments as? Dictionary<String, Any?>,
           let remote = args["remote"] as? String {
            hungup(remote: remote, result: result)
        } else {
            result("param error")
        }
    case "answerCall":
        // 接听远端呼叫
        answerCall()
    case "declineCall":
        // 挂断远端呼叫
        declineCall()
    default:
        result(nil)
    }
  }
    
    // 直接调用rtm
    private func startOutgoingCall(remoteNumber: String, result: @escaping FlutterResult) {
        guard let kit = AgoraRtm.shared().kit else {
            fatalError("rtm kit nil")
        }
        guard let inviter = AgoraRtm.shared().inviter else {
            fatalError("rtm inviter nil")
        }

        print("startOutgoingCall")
        // rtm query online status
        kit.queryPeerOnline(remoteNumber, success: {(onlineStatus) in
            switch onlineStatus {
            case .online: sendInvitation(remote: remoteNumber, channel: "test")
            case .offline: result("peer offline")
            case .unreachable: result("peer unreachable")
            @unknown default:  fatalError("queryPeerOnline")
            }
        }) { [weak self] (error) in
            result(error.localizedDescription)
        }

        // rtm send invitation
        func sendInvitation(remote: String, channel: String) {
//            let channel = "\(localNumber)-\(remoteNumber)-\(Date().timeIntervalSinceReferenceDate)"
            print("sendInvitation")
            inviter.sendInvitation(peer: remoteNumber, extraContent: channel, accepted: { [weak self] in
                guard let remote = UInt(remoteNumber) else {
                    fatalError("string to int fail")
                }

                var data: (channel: String, remote: UInt)
                data.channel = channel
                data.remote = remote
                print("call connect success: \(data)")
                // 本地呼叫邀请成功
                self?.methodChannel.invokeMethod("localInvitationAccept", arguments: [
                    "channel": channel,
                    "remote": remoteNumber
                ])
                result("success")
            }, refused: { [weak self] in
                // 本地呼叫邀请被拒绝
                self?.methodChannel.invokeMethod("localInvitationRefused", arguments: [
                    "remote": remote,
                    "channel": channel
                ])
            }) { [weak self] (error) in
                result(error)
            }
        }
    }
    
    private func answerCall() {
        guard let inviter = AgoraRtm.shared().inviter else {
            fatalError("rtm inviter nil")
        }
        inviter.accpetLastIncomingInvitation()
    }
    
    private func declineCall() {
        print("callCenter declineCall")
        
        guard let inviter = AgoraRtm.shared().inviter else {
            fatalError("rtm inviter nil")
        }

        inviter.refuseLastIncomingInvitation {  [weak self] (error) in
            print(error.localizedDescription)
        }
    }
    
    private func login(account: String, token: String, result: @escaping FlutterResult) {
        guard let kit = AgoraRtm.shared().kit else {
            print("AgoraRtmKit nil")
            return
        }
        
        kit.login(account: account, token: token, success: {
            result("success")
        }, fail:  {(error) in
            result(error.localizedDescription)
        })
    }
    
    private func logout(result: @escaping FlutterResult) {
        guard let kit = AgoraRtm.shared().kit else {
            print("AgoraRtmKit nil")
            return
        }
        kit.logout(completion: { errorCode in
            if errorCode == AgoraRtmLogoutErrorCode.ok {
                result("success")
            } else {
                result("failure")
            }
        })
    }
    
    private func hungup(remote: String, result: @escaping FlutterResult) {
        guard let inviter = AgoraRtm.shared().inviter else {
            fatalError("rtm inviter nil")
        }
        
        let errorHandle: ErrorCompletion = { (error: AGEError) in
//            self.view().makeToast(error.localizedDescription, duration: 1.0)
            result(error.localizedDescription)
        }
        
        switch inviter.status {
        case .outgoing:
//            self.appleCallKit.endCall(of: remote)
            inviter.cancelLastOutgoingInvitation(fail: errorHandle)
            result("success")
        default:
            break
        }
    }
}

extension SwiftFlutterAgoraMessengerPlugin: AgoraRtmInvitertDelegate {
    func inviter(_ inviter: AgoraRtmCallKit, didReceivedIncoming invitation: AgoraRtmInvitation) {
        // remoteInvitationReceived
        methodChannel.invokeMethod("remoteInvitationReceived", arguments: [
            "remote": invitation.caller,
            "channel": invitation.content
        ])
    }
    
    func inviter(_ inviter: AgoraRtmCallKit, remoteDidCancelIncoming invitation: AgoraRtmInvitation) {
        // remoteInvitationCanceled
        methodChannel.invokeMethod("remoteInvitationCanceled", arguments: [
            "remote": invitation.caller,
            "channel": invitation.content
        ])
    }
    
    func inviter(_ inviter: AgoraRtmCallKit, remoteDidRefused invitation: AgoraRtmInvitation) {
        methodChannel.invokeMethod("remoteInvitationRefused", arguments: [
            "remote": invitation.caller,
            "channel": invitation.content
        ])
    }
    
    func inviter(_ inviter: AgoraRtmCallKit, remoteDidAccept invitation: AgoraRtmInvitation) {
        methodChannel.invokeMethod("remoteInvitationAccepted", arguments: [
            "remote": invitation.caller,
            "channel": invitation.content
        ])
    }
}

