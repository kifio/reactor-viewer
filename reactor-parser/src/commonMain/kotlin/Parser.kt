import io.ktor.client.HttpClient
import io.ktor.client.engine.HttpClientEngine
import io.ktor.client.features.cookies.AcceptAllCookiesStorage
import io.ktor.client.features.cookies.CookiesStorage
import io.ktor.client.features.cookies.HttpCookies
import io.ktor.client.request.get
import io.ktor.http.Cookie
import io.ktor.http.Url
import kotlinx.coroutines.*
import kotlinx.serialization.*
import kotlinx.serialization.json.*

/**
 * Публичный апи парсера.
 */
class Reactor(engine: HttpClientEngine? = null) {

    companion object {
        private const val BASE_URL = "http://joyreactor.cc/tag"
        private const val START_JSON_TAG = "<script type=\"application/ld+json\">"
        private const val FINISH_JSON_TAG = "</script>"
        private const val FOO = "@"
        private const val BAR = ""
        private const val BUZ = "\\"
        private const val SLASH = "/"
        private const val TAG_DELIMITER = "::"
    }

    private val client: HttpClient
    private val json: Json = Json(JsonConfiguration.Stable.copy(ignoreUnknownKeys = true))

    init {
        if (engine != null) {
            client = HttpClient(engine) {
                install(HttpCookies) {
                    storage = CustomCookieStorage(AcceptAllCookiesStorage())
                }
            }
        } else {
            client = HttpClient() {
                install(HttpCookies) {
                    storage = CustomCookieStorage(AcceptAllCookiesStorage())
                }
            }
        }
    }

    suspend fun getLastPage(tag: String): Pair<Int?, List<Post>>  {
        val html = client.get<String>("$BASE_URL/$tag")

        val tags = html.split("<span class='current'>")
        for (i in 1 until tags.size) {
            val page = tags[i].substring(0, tags[i].indexOf("</span>")).toIntOrNull()
            if (page != null) {
                return Pair(page, parseHtml(html))
            }
            println()
        }

        return Pair(0, emptyList())
    }

    fun getPage(page: Int): List<Post>{
        return emptyList()
    }

    private fun parseHtml(html: String): List<Post> {
        val posts = html.split(START_JSON_TAG)
        val entities = mutableListOf<Post>()

        for (i in 1 until posts.size - 1) {

            val jsonString = posts[i].substring(0, posts[i].indexOf(FINISH_JSON_TAG))
                .replace(FOO, BAR)
                .replace(BUZ, BAR)
                .trim()

            entities.add(
                json.parse(Post.serializer(), jsonString).apply {
                    val endOfTrash = headline.indexOf(SLASH)
                    if (endOfTrash != -1) {
                        headline = headline.substring(endOfTrash + 1)
                    }
                }
            )
        }

        return entities
    }

    @Serializable
    data class Post(
        val type: String,
        var headline: String,
        val image: Image? = null
    )

    @Serializable
    data class Image(
        val type: String,
        val url: String?
    )

    data class Out(val tags: MutableList<String>, val url: String)

    private class CustomCookieStorage(private val defaultStorage: CookiesStorage): CookiesStorage {

        override suspend fun get(requestUrl: Url): List<Cookie> {
            return defaultStorage.get(requestUrl)
        }

        override suspend fun addCookie(requestUrl: Url, cookie: Cookie) {
            defaultStorage.addCookie(requestUrl, cookie)
        }

        override fun close() {

        }
    }
}