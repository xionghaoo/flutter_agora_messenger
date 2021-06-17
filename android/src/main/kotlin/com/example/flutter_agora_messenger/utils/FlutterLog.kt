package com.example.flutter_agora_messenger.utils

import io.flutter.Log

class FlutterLog {
    companion object {
        fun d(tag: String?, message: String?) {
            Log.d(tag!!, message!!)
        }

        fun i(tag: String?, message: String?) {
            Log.i(tag!!, message!!)
        }
    }
}