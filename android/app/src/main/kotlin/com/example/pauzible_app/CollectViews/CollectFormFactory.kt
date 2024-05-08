// package com.example.pauzible_app.CollectViews

// import Skyflow.Client
// import Skyflow.CollectContainer
// import android.content.Context
// import io.flutter.Log
// import io.flutter.plugin.common.StandardMessageCodec
// import io.flutter.plugin.platform.PlatformView
// import io.flutter.plugin.platform.PlatformViewFactory
// import io.flutter.embedding.engine.FlutterEngine

// public class CollectFormFactory(flutterEngine: FlutterEngine, client: Client) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

//     var client: Client
//     var flutterEngine: FlutterEngine

//     init {
//         this.client = client
//         this.flutterEngine = flutterEngine
//     }
//     override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
//         val creationParams = args as Map<String?, Any?>?
//         return CollectForm(context, viewId, flutterEngine, client, creationParams)
//     }
// }