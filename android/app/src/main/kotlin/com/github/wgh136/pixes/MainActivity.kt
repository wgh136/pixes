package com.github.wgh136.pixes

import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        //获取http代理
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "pixes/proxy"
        ).setMethodCallHandler { _, res ->
            res.success(getProxy())
        }
    }

    private fun getProxy(): String{
        val host = System.getProperty("http.proxyHost")
        val port = System.getProperty("http.proxyPort")
        return if(host!=null&&port!=null){
            "$host:$port"
        }else{
            "No Proxy"
        }
    }
}