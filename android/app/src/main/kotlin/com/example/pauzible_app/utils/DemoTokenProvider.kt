// package com.example.pauzible_app.utils

// import Skyflow.Callback
// import org.json.JSONObject
// import java.io.IOException
// import okhttp3.OkHttpClient

// internal class DemoTokenProvider: Skyflow.TokenProvider {
//     override fun getBearerToken(callback: Callback) {
//         val url = "<YOUR_TOKEN_ENDPOINT_URL>"
//         val request = okhttp3.Request.Builder().url(url).build()
//         val okHttpClient = OkHttpClient()
//         try {
//             val thread = Thread {
//                 run {
//                     okHttpClient.newCall(request).execute().use { response ->
//                         if (!response.isSuccessful)
//                             throw IOException("Unexpected code $response")
//                         val accessTokenObject = JSONObject(
//                             response.body!!.string().toString()
//                             )
//                         val accessToken = accessTokenObject["accessToken"]
//                         callback.onSuccess("$accessToken")
//                     }
//                 }
//             }
//             thread.start()
//         }catch (exception:Exception){
//             callback.onFailure(exception)
//         }
//     }

// }