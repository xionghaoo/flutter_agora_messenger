import Flutter
import UIKit
import AgoraRtmKit
//import Toast_Swift

public class SwiftFlutterAgoraMessengerPlugin: NSObject, FlutterPlugin {

    private lazy var appleCallKit = CallCenter(delegate: self)
    private var localNumber: String?
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
//            rtm.initialRtmKit(appId: appId)
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
    case "startOutgoingCall":
        if let args = call.arguments as? Dictionary<String, Any?>,
           let number = args["phoneNumber"] as? String {
            localNumber = number
            appleCallKit.startOutgoingCall(of: number)
            result(nil)
        } else {
            result("param error")
        }
    case "endCall":
        if let args = call.arguments as? Dictionary<String, Any?>,
           let remote = args["remote"] as? String {
            appleCallKit.endCall(of: remote)
            result(nil)
        } else {
            result("param error")
        }
    case "hungUp":
        if let args = call.arguments as? Dictionary<String, Any?>,
           let remote = args["remote"] as? String {
            hungup(remote: remote, result: result)
        } else {
            result("param error")
        }
    default:
        result(nil)
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
            self.appleCallKit.endCall(of: remote)
            inviter.cancelLastOutgoingInvitation(fail: errorHandle)
            result("success")
        default:
            break
        }
    }
}

extension SwiftFlutterAgoraMessengerPlugin: AgoraRtmInvitertDelegate {
    func inviter(_ inviter: AgoraRtmCallKit, didReceivedIncoming invitation: AgoraRtmInvitation) {
        appleCallKit.showIncomingCall(of: invitation.caller)
        
    }
    
    func inviter(_ inviter: AgoraRtmCallKit, remoteDidCancelIncoming invitation: AgoraRtmInvitation) {
        appleCallKit.endCall(of: invitation.caller)
//        if let vc = self.presentedViewController as? VideoChatViewController {
//            vc.leaveChannel()
//            vc.dismiss(animated: true, completion: nil)
//        }
    }
}

extension SwiftFlutterAgoraMessengerPlugin: CallCenterDelegate {
    func callCenter(_ callCenter: CallCenter, answerCall session: String) {
        // 接听电话
        print("callCenter answerCall")
                
        guard let inviter = AgoraRtm.shared().inviter else {
            fatalError("rtm inviter nil")
        }

        guard let channel = inviter.lastIncomingInvitation?.content else {
            fatalError("lastIncomingInvitation content nil")
        }

        guard let remote = UInt(session) else {
            fatalError("string to int fail")
        }

        inviter.accpetLastIncomingInvitation()
        methodChannel.invokeMethod("answerCall", arguments: ["channel": channel, "remote": remote])
        // present VideoChat VC after 'callCenterDidActiveAudioSession'
//        self.prepareToVideoChat = { [weak self] in
//            var data: (channel: String, remote: UInt)
//            data.channel = channel
//            data.remote = remote
//            self?.performSegue(withIdentifier: "DialToVideoChat", sender: data)
//        }
    }
    
    func callCenter(_ callCenter: CallCenter, declineCall session: String) {
        print("callCenter declineCall")
        
        guard let inviter = AgoraRtm.shared().inviter else {
            fatalError("rtm inviter nil")
        }

        inviter.refuseLastIncomingInvitation {  [weak self] (error) in
//            self?.showAlert(error.localizedDescription)
            print(error.localizedDescription)
        }
    }
    
    func callCenter(_ callCenter: CallCenter, startCall session: String) {
        // 开始呼叫
        print("callCenter startCall")
        
        guard let kit = AgoraRtm.shared().kit else {
            fatalError("rtm kit nil")
        }

        guard let localNumber = localNumber else {
            fatalError("localNumber nil")
        }

        guard let inviter = AgoraRtm.shared().inviter else {
            fatalError("rtm inviter nil")
        }

//        guard let vc = self.presentedViewController as? CallingViewController else {
//            fatalError("CallingViewController nil")
//        }

        let remoteNumber = session

        // rtm query online status
        kit.queryPeerOnline(remoteNumber, success: {(onlineStatus) in
            switch onlineStatus {
            case .online:      sendInvitation(remote: remoteNumber)
            case .offline: print("peer offline")
            case .unreachable: print("peer unreachable")
            @unknown default:  fatalError("queryPeerOnline")
            }
        }) { [weak self] (error) in
            self?.methodChannel.invokeMethod("close", arguments: [
                "type": "error",
                "value": error
            ])
//            vc?.close(.error(error))
        }

        // rtm send invitation
        func sendInvitation(remote: String) {
            let channel = "\(localNumber)-\(remoteNumber)-\(Date().timeIntervalSinceReferenceDate)"

            inviter.sendInvitation(peer: remoteNumber, extraContent: channel, accepted: { [weak self] in
//                vc?.close(.toVideoChat)

                self?.appleCallKit.setCallConnected(of: remote)

                guard let remote = UInt(remoteNumber) else {
                    fatalError("string to int fail")
                }

                var data: (channel: String, remote: UInt)
                data.channel = channel
                data.remote = remote
                print("call connect success: \(data)")
                // 呼叫邀请成功跳转到视频通话页面
                self?.methodChannel.invokeMethod("localInvitationAccept", arguments: [
                    "channel": channel,
                    "remote": remote
                ])
//                self?.performSegue(withIdentifier: "DialToVideoChat", sender: data)

            }, refused: { [weak self] in
                print("remote reject")
                self?.methodChannel.invokeMethod("close", arguments: [
                    "type": "remoteReject",
                    "value": remoteNumber
                ])
//                vc?.close(.remoteReject(remoteNumber))
            }) { [weak self] (error) in
                print("error: \(error)")
                self?.methodChannel.invokeMethod("close", arguments: [
                    "type": "error",
                    "value": error
                ])
//                vc?.close(.error(error))
            }
        }
    }
    
    func callCenter(_ callCenter: CallCenter, muteCall muted: Bool, session: String) {
        print("callCenter muteCall")
    }
    
    func callCenter(_ callCenter: CallCenter, endCall session: String) {
        print("callCenter endCall")
//        self.prepareToVideoChat = nil
    }
    
    func callCenterDidActiveAudioSession(_ callCenter: CallCenter) {
        print("callCenter didActiveAudioSession")
        
        // Incoming call
//        if let prepare = self.prepareToVideoChat {
//            prepare()
//        }
    }
    
}
