// package com.example.pauzible_app.utils

// import Skyflow.Callback
// import io.flutter.plugin.common.MethodChannel

// internal class DemoCallback(result: MethodChannel.Result): Callback {

//     private var result: MethodChannel.Result


//     init {
//         this.result = result
//     }

//     override fun onFailure(exception: Any) {
//         result.error("500", "Operation Failed", null)
//     }

//     override fun onSuccess(responseBody: Any) {
//         result.success(responseBody.toString())
//     }

// }