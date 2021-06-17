package com.example.flutter_agora_messenger

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.widget.Toast
import androidx.annotation.NonNull
import com.example.flutter_agora_messenger.utils.FileUtil
import com.example.flutter_agora_messenger.utils.FlutterLog
import com.example.flutter_agora_messenger.utils.RtcUtils
import io.agora.rtm.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FlutterAgoraMessengerPlugin */
class FlutterAgoraMessengerPlugin: FlutterPlugin, MethodCallHandler, IEventListener {

  companion object {
    private const val TAG = "FlutterAgoraMessenger"
  }

  private lateinit var methodChannel : MethodChannel
  private lateinit var mRtmClient: RtmClient
  private lateinit var rtmCallManager: RtmCallManager
  private var mEventListener: EngineEventListener? = null
  private var context: Context? = null
  private var config: Config? = null
  private var global: Global? = null
  private var localNumber: String? = null

  private val handler = Handler(Looper.getMainLooper())

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_agora_messenger")
    methodChannel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "initial" -> {
        val appId = call.argument<String>("appId")
        if (appId != null) {
          initial(context!!, appId)
        } else {
          throw IllegalArgumentException("App ID is null")
        }
      }
      "login" -> {
        val token = call.argument<String>("token")
        val account = call.argument<String>("account")
        if (token != null && account != null) {
          login(token, account, result)
        }
      }
      "startOutgoingCall" -> {
        val phoneNumber = call.argument<String>("phoneNumber")
        if (phoneNumber != null) {
          startOutgoingCall(phoneNumber)
        }
      }
      "hungUp" -> {
        val remote = call.argument<String>("remote")
        if (remote != null) {
          hungUp(remote, result)
        }
      }
      "answer" -> {
        answer(result)
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    methodChannel.setMethodCallHandler(null)
    context = null
  }

  private fun initial(applicationContext: Context, appid: String?) {
    mEventListener = EngineEventListener()
    mEventListener?.registerEventListener(this)

    config = Config(applicationContext)
    global = Global()

    mRtmClient = RtmClient.createInstance(applicationContext, appid, mEventListener)
    mRtmClient.setLogFile(FileUtil.rtmLogFile(applicationContext))

    rtmCallManager = mRtmClient.rtmCallManager
    rtmCallManager.setEventListener(mEventListener)
  }

  private fun login(token: String, userId: String, result: Result) {
    mRtmClient.login(token, userId, object : ResultCallback<Void?> {
      override fun onSuccess(aVoid: Void?) {
        FlutterLog.i(TAG, "rtm client login success")
        localNumber = userId
        handler.post {
          result.success("success")
        }
      }

      override fun onFailure(errorInfo: ErrorInfo) {
        handler.post {
          result.error("100", errorInfo.errorDescription, null)
        }
        FlutterLog.i(
          TAG,
          "rtm client login failed:" + errorInfo.errorDescription
        )
      }
    })
  }

  private fun startOutgoingCall(peer: String) {
//    val number: Int = mCallInputManager.getCallNumber()
    val peerSet: MutableSet<String> = HashSet()
    peerSet.add(peer)
    mRtmClient.queryPeersOnlineStatus(peerSet, object : ResultCallback<Map<String?, Boolean?>> {
      override fun onSuccess(statusMap: Map<String?, Boolean?>) {
        val bOnline = statusMap[peer]
        if (bOnline != null && bOnline) {
          // 对方在线
//          val uid: String = java.lang.String.valueOf(mActivity.application().config().getUserId())
          val channel: String = RtcUtils.channelName(localNumber, peer)
//          mActivity.gotoCallingInterface(peer, channel, Constants.ROLE_CALLER)

          val invitation: LocalInvitation = rtmCallManager.createLocalInvitation(peer)
          invitation.content = channel
          rtmCallManager.sendLocalInvitation(invitation, object : ResultCallback<Void> {
            override fun onSuccess(p0: Void?) {

            }

            override fun onFailure(p0: ErrorInfo?) {
              handler.post {
                val args = HashMap<String, String?>()
                args.put("type", "error")
                args.put("value", p0?.errorDescription)
                methodChannel.invokeMethod("close", args)
              }
            }
          })
          global?.localInvitation = invitation
        } else {
          // 对方不在线
            handler.post {
              Toast.makeText(context, "您呼叫的用户不在线", Toast.LENGTH_SHORT).show()
            }
//          mActivity.runOnUiThread(Runnable {
//            Toast.makeText(
//              mActivity,
//              R.string.peer_not_online,
//              Toast.LENGTH_SHORT
//            ).show()
//          })
        }
      }

      override fun onFailure(errorInfo: ErrorInfo) {}
    })
  }

  private fun hungUp(remote: String, result: Result) {
    rtmCallManager.cancelLocalInvitation(global?.localInvitation, object : ResultCallback<Void> {
      override fun onSuccess(p0: Void?) {
        handler.post {
          result.success("success")
        }
      }

      override fun onFailure(p0: ErrorInfo?) {
        handler.post {
          result.error("200", p0?.errorDescription, null)
        }
      }
    })
  }

  private fun answer(result: Result) {
    rtmCallManager.acceptRemoteInvitation(global?.remoteInvitation, object : ResultCallback<Void> {
      override fun onSuccess(p0: Void?) {
        handler.post {
          result.success("success")
        }
      }

      override fun onFailure(p0: ErrorInfo?) {
        handler.post {
          result.success(p0?.errorDescription)
        }
      }
    })
  }

  override fun onJoinChannelSuccess(channel: String?, uid: Int, elapsed: Int) {
    FlutterLog.d(TAG, "onJoinChannelSuccess: $channel, $uid, $elapsed")

  }

  override fun onUserJoined(uid: Int, elapsed: Int) {
    FlutterLog.d(TAG, "onUserJoined: $uid, $elapsed")

  }

  override fun onUserOffline(uid: Int, reason: Int) {
    FlutterLog.d(TAG, "onUserOffline")

  }

  override fun onConnectionStateChanged(status: Int, reason: Int) {
    FlutterLog.d(TAG, "onConnectionStateChanged")

  }

  override fun onPeersOnlineStatusChanged(map: MutableMap<String, Int>?) {
    FlutterLog.d(TAG, "onPeersOnlineStatusChanged")
  }

  override fun onLocalInvitationReceived(localInvitation: LocalInvitation?) {
    FlutterLog.d(TAG, "onLocalInvitationReceived: ${localInvitation?.calleeId}, ${localInvitation?.channelId}")

  }

  override fun onLocalInvitationAccepted(localInvitation: LocalInvitation?, response: String?) {
    FlutterLog.d(TAG, "onLocalInvitationAccepted: ${localInvitation?.calleeId}, ${localInvitation?.channelId}")
  }

  override fun onLocalInvitationRefused(localInvitation: LocalInvitation?, response: String?) {
    handler.post {
      // 本地呼叫 - 对方拒绝
      val args = HashMap<String, String?>()
      args.put("type", "remoteReject")
      args.put("value", localInvitation?.calleeId)
      methodChannel.invokeMethod("close", args)
      FlutterLog.d(TAG, "onLocalInvitationRefused: ${localInvitation?.calleeId}, ${localInvitation?.channelId}")
    }
  }

  override fun onLocalInvitationCanceled(localInvitation: LocalInvitation?) {
    FlutterLog.d(TAG, "onLocalInvitationCanceled: ${localInvitation?.calleeId}, ${localInvitation?.channelId}")

  }

  override fun onLocalInvitationFailure(localInvitation: LocalInvitation?, errorCode: Int) {
    FlutterLog.d(TAG, "onLocalInvitationFailure: ${localInvitation?.calleeId}, ${localInvitation?.channelId}")

  }

  override fun onRemoteInvitationReceived(remoteInvitation: RemoteInvitation?) {
    // 对方呼叫 - 本地待接听
    FlutterLog.d(TAG, "onRemoteInvitationReceived: ${remoteInvitation?.callerId}, ${remoteInvitation?.channelId}")
    global?.remoteInvitation = remoteInvitation
    handler.post {
      val args = HashMap<String, String?>()
      args.put("channel", remoteInvitation?.channelId)
      args.put("remote", remoteInvitation?.callerId)
      methodChannel.invokeMethod("onRemoteInvitationReceived", args)
    }
  }

  override fun onRemoteInvitationAccepted(remoteInvitation: RemoteInvitation?) {
    FlutterLog.d(TAG, "onRemoteInvitationAccepted: ${remoteInvitation?.callerId}, ${remoteInvitation?.channelId}")

  }

  override fun onRemoteInvitationRefused(remoteInvitation: RemoteInvitation?) {
    FlutterLog.d(TAG, "onRemoteInvitationRefused: ${remoteInvitation?.callerId}, ${remoteInvitation?.channelId}")

  }

  override fun onRemoteInvitationCanceled(remoteInvitation: RemoteInvitation?) {
    FlutterLog.d(TAG, "onRemoteInvitationCanceled: ${remoteInvitation?.callerId}, ${remoteInvitation?.channelId}")

  }

  override fun onRemoteInvitationFailure(remoteInvitation: RemoteInvitation?, errorCode: Int) {
    FlutterLog.d(TAG, "onRemoteInvitationFailure: ${remoteInvitation?.callerId}, ${remoteInvitation?.channelId}")

  }
}