// package com.example.pauzible_app.CollectViews

// import Skyflow.*
// import Skyflow.utils.EventName
// import android.content.Context
// import android.graphics.Color
// import android.view.View
// import android.widget.EditText
// import android.widget.LinearLayout
// import android.widget.TextView
// import com.example.pauzible_app.utils.DemoCallback
// import io.flutter.Log
// import io.flutter.embedding.engine.FlutterEngine
// import io.flutter.plugin.common.MethodChannel
// import io.flutter.plugin.platform.PlatformView

// internal class CollectForm(context: Context, id: Int, flutterEngine: FlutterEngine, client: Client, creationParams: Map<String?, Any?>?) :
//         PlatformView {
//     private val collectForm = LinearLayout(context);

//     override fun getView(): View {
//         return collectForm
//     }

//     private val collectContainer = client.container(ContainerType.COLLECT)

//     override fun dispose() {}

//     init {
//         val CHANNEL = "skyflow-collect/${id}"
//         collectForm.orientation = LinearLayout.VERTICAL
//         val fields = creationParams?.get("fields") as Map<String, ArrayList<String>>
//         for((label, values) in fields) {
//             val collectInput = CollectElementInput(
//                     table=values[0],
//                     column=values[1],
//                     label=label,
//                     type=getElementType(values[2]),
//                     inputStyles = getDefaultStyles()
//             )

//             val textfield = collectContainer.create(context, collectInput, options = CollectElementOptions(format="mm/yy"))
//             collectForm.addView(textfield)
//         }

//         MethodChannel(flutterEngine.dartExecutor, CHANNEL).setMethodCallHandler{ call, result ->
//         if (call.method == "COLLECT") {
//             Log.d("MC", "Collect has been called")
//             this.collectContainer.collect(DemoCallback(result), CollectOptions())
//         } else {
//             result.notImplemented()
//         }}

//         collectForm.setBackgroundColor(Color.rgb(255, 255, 255))

//     }

//     private fun getElementType(type: String): SkyflowElementType {
//         if(type == "CARD_NUMBER") {
//             return SkyflowElementType.CARD_NUMBER
//         } else if (type.equals("CARDHOLDER_NAME")) {
//             return SkyflowElementType.CARDHOLDER_NAME
//         } else if(type.equals("CVV")) {
//             return SkyflowElementType.CVV
//         } else if(type.equals("EXPIRATION_DATE")) {
//             return SkyflowElementType.EXPIRATION_DATE
//         } else if(type.equals("PIN")) {
//             return SkyflowElementType.PIN;
//         } else {
//             return SkyflowElementType.INPUT_FIELD
//         }
//     }
// }

// private fun getDefaultStyles() : Styles {
//     val padding = Padding(8, 8, 8, 8)
//     val base = Style(
//             Color.BLACK,
//             10f,
//             padding,
//             1,
//             R.font.roboto_light,
//             Gravity.START,
//             Color.BLUE
//     )
//     val complete = Style(
//             Color.GREEN,
//             10f,
//             padding,
//             1,
//             R.font.roboto_light,
//             Gravity.END,
//             Color.GREEN
//     )
//     val focus = Style(
//             Color.BLACK,
//             10f,
//             padding,
//             1,
//             R.font.roboto_light,
//             Gravity.START,
//             Color.GREEN
//     )
//     val empty = Style(
//             Color.YELLOW,
//             10f,
//             padding,
//             1,
//             R.font.roboto_light,
//             Gravity.CENTER,
//             Color.YELLOW
//     )
//     val invalid = Style(Color.RED, 10f, padding, 1, R.font.roboto_light, Gravity.START, Color.RED)
//     return Styles(base, complete, empty, focus, invalid)
// }