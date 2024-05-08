// package com.example.pauzible_app.RevealViews

// import Skyflow.Client
// import Skyflow.Container
// import Skyflow.ContainerType
// import Skyflow.RevealContainer
// import android.content.Context
// import io.flutter.plugin.common.StandardMessageCodec
// import io.flutter.plugin.platform.PlatformView
// import io.flutter.plugin.platform.PlatformViewFactory
// import io.flutter.embedding.engine.FlutterEngine

// internal class RevealFormFactory(flutterEngine: FlutterEngine, client: Client) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

//     private var client: Client
//     private var flutterEngine: FlutterEngine

//     init {
//         this.client = client
//         this.flutterEngine = flutterEngine
//     }
//     override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
//         val creationParams = args as Map<String?, Any?>?
//         val revealLabel =  RevealForm(context, viewId, flutterEngine, client, creationParams)


//         return revealLabel
//     }
// }