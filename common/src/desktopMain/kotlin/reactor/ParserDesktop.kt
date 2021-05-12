package reactor

import io.ktor.client.*
import io.ktor.client.engine.java.*
import io.ktor.client.features.cookies.*
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers

internal actual val Main: CoroutineDispatcher = Dispatchers.Main

internal actual val Background: CoroutineDispatcher = Dispatchers.Default

internal actual val client = HttpClient(Java) {
    install(HttpCookies) {
        storage = CustomCookieStorage(AcceptAllCookiesStorage())
    }
}