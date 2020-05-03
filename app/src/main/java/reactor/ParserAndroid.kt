package reactor

import android.app.Activity
import android.os.Bundle
import android.widget.TextView
//import io.ktor.client.HttpClient
//import io.ktor.client.engine.okhttp.OkHttp
//import io.ktor.client.features.cookies.AcceptAllCookiesStorage
//import io.ktor.client.features.cookies.HttpCookies
//import kotlinx.coroutines.CoroutineDispatcher
//import kotlinx.coroutines.Dispatchers

//internal actual val Main: CoroutineDispatcher = Dispatchers.Main
//
//internal actual val Background: CoroutineDispatcher = Dispatchers.Default
//
//internal actual val client = HttpClient(OkHttp) {
//    install(HttpCookies) {
//        storage = CustomCookieStorage(AcceptAllCookiesStorage())
//    }
//}

class MainActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        findViewById<TextView>(R.id.main_text).text = ""
    }
}