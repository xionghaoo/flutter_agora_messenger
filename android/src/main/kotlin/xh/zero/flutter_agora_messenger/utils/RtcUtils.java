package xh.zero.flutter_agora_messenger.utils;

public class RtcUtils {
    public static String channelName(String myUid, String peerUid) {
        return myUid + peerUid;
    }
}
