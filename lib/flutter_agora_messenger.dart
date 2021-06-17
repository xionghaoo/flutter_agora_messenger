
import 'dart:async';

import 'package:flutter/services.dart';

typedef AnswerCall(String channel, int remote);
typedef CloseCallback(String type, String value);
typedef LocalInvitationAccept(String channel, int remote);
typedef OnRemoteInvitationReceived(String channel, String remote);

class FlutterAgoraMessenger {
  
  static FlutterAgoraMessenger? _instance;
  
  factory FlutterAgoraMessenger() {
    if (_instance == null) {
      final _methodChannel = MethodChannel('flutter_agora_messenger');
      _instance = FlutterAgoraMessenger._(_methodChannel);
    }
    return _instance!;
  }

  AnswerCall? _answerCall;
  LocalInvitationAccept? _localInvitationAccept;
  OnRemoteInvitationReceived? _onRemoteInvitationReceived;
  CloseCallback? _closeCallback;

  FlutterAgoraMessenger._(this._methodChannel) {
    _methodChannel.setMethodCallHandler((call) {
      print("call: ${call.method}");
      switch (call.method) {
        case "answerCall":
          // 对方呼叫，本地应答
          final channel = call.arguments["channel"] as String;
          final remote = call.arguments["remote"] as int;
          _answerCall?.call(channel, remote);
          break;
        case "localInvitationAccept":
          // 本地呼叫，对方应答
          final channel = call.arguments["channel"] as String;
          final remote = call.arguments["remote"] as int;
          _localInvitationAccept?.call(channel, remote);
          break;
        case "close":
          final type = call.arguments["type"] as String;
          if (type == "remoteReject") {
            final remoteNumber = call.arguments["value"] as String;
            endCall(remoteNumber);
            _closeCallback?.call(type, remoteNumber);
          } else if (type == "error") {
            final error = call.arguments["value"] as String;
            _closeCallback?.call(type, error);
          }
          break;
          // Android端的远程呼叫邀请
        case "onRemoteInvitationReceived":
          final channel = call.arguments["channel"] as String;
          final remote = call.arguments["remote"] as String;
          _onRemoteInvitationReceived?.call(channel, remote);
          break;
      }
      return Future.value(null);
    });
    
  }
  
  late final MethodChannel _methodChannel;

  initial(String appId) {
    _methodChannel.invokeMethod("initial", {
      "appId": appId
    });
  }
  
  Future<String?> login(String account, String token) async {
    return _methodChannel.invokeMethod<String>("login", {
      "account" : account,
      "token": token
    });
  }

  startOutgoingCall(String phoneNumber) {
    _methodChannel.invokeMethod("startOutgoingCall", {
      "phoneNumber": phoneNumber
    });
  }
  
  endCall(String remote) {
    _methodChannel.invokeMethod("endCall", {
      "remote": remote
    });
  }

  Future<String> hungUp(String remote) async {
    return await _methodChannel.invokeMethod("hungUp", {
      "remote": remote
    });
  }

  Future<String> answer() async {
    return await _methodChannel.invokeMethod("answer");
  }

  setAnswerCallback(AnswerCall answerCall) {
    _answerCall = answerCall;
  }

  setLocalInvitationAccept(LocalInvitationAccept call) {
    _localInvitationAccept = call;
  }

  setOnRemoteInvitationReceived(OnRemoteInvitationReceived call) {
    _onRemoteInvitationReceived = call;
  }

  setCloseCallback(CloseCallback callback) {
    _closeCallback = callback;
  }


}
