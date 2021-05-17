package reactor

import com.benasher44.uuid.uuid4
import io.ktor.client.HttpClient
import io.ktor.client.features.cookies.CookiesStorage
import io.ktor.client.request.get
import io.ktor.http.Cookie
import io.ktor.http.Url
import kotlinx.coroutines.*
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json

internal expect val Main: CoroutineDispatcher

expect val Background: CoroutineDispatcher

internal expect val client: HttpClient

class Reactor {

    companion object {
        private const val BASE_URL = "http://joyreactor.cc/tag"
        private const val START_JSON_TAG = "<script type=\"application/ld+json\"> "
        private const val FINISH_JSON_TAG = "} </script>"
        private const val FOO = "@"
        private const val BAR = ""
        private const val BUZ = "\\"
        private const val SLASH = "/"
        private const val TAG_DELIMITER = "::"
        private const val POST_SEPARATOR = "id=\"postContainer"
        private const val START_PHOTO_TAG = "prettyPhoto\"><img src=\""
        private const val FINISH_PHOTO_TAG = "\" width=\""

        private const val DELAY = 1000L
    }

    private val backgroundScope = CoroutineScope(Background)
    private val format = Json { ignoreUnknownKeys = true; encodeDefaults = false }

    fun getLastPage(tag: String, reactorController: ReactorPageHandler) {
        backgroundScope.launch(Background) {
            val html = client.get<String>("$BASE_URL/$tag")
            val tags = html.split("<span class='current'>")
            var page: Int? = null

            for (i in 1 until tags.size) {
                page = tags[i].substring(0, tags[i].indexOf("</span>")).toIntOrNull()
                if (page != null) {
                    val posts = parseHtml(html)
                    withContext(Main) {
                        delay(DELAY)
                        reactorController.onPageLoaded(tag, page, posts)
                    }
                }
            }

            if (page == null) {
                withContext(Main) {
                    reactorController.onPageLoaded(tag, 0, emptyList())
                }
            }
        }
    }

    fun getPage(tag: String, page: Int, reactorController: ReactorPageHandler) {
        backgroundScope.launch(Background) {
            val html = client.get<String>("$BASE_URL/$tag/$page")
            val posts = parseHtml(html)
            withContext(Main) {
                delay(DELAY)
                reactorController.onPageLoaded(tag, page, posts)
            }
        }
    }

    fun dispose() = backgroundScope.cancel()

    private fun parseHtml(html: String): List<Post> {
        // Split page by posts
        val posts = html.split(POST_SEPARATOR)
        val entities = mutableListOf<Post>()

//        println("parseHtml")

        // Skip everything before first post
        for (i in 1 until posts.size) {

            val startIndex = posts[i].indexOf(START_JSON_TAG)
            val finishIndex = posts[i].indexOf(FINISH_JSON_TAG)

            if (startIndex > 0 && finishIndex > 0) {

                val jsonString = posts[i].substring(
                    startIndex + START_JSON_TAG.length,
                    finishIndex + 1
                ) // finish tag includes closing bracket of json
                    .trim() // start tag not includes whitespace between tag and json
                    .replace(FOO, BAR)
                    .replace(BUZ, BAR)

//                println(jsonString)

                val rawPost = format.decodeFromString(RawPost.serializer(), jsonString).apply {
                    val endOfTrash = headline.indexOf(SLASH)
                    if (endOfTrash != -1) {
                        headline = headline.substring(endOfTrash + 1)
                    }
                }

                val url = rawPost.image?.url ?: continue
                val tags =
                    rawPost.headline.split(TAG_DELIMITER).map { tag -> tag.trim() }.toMutableList()
                val dateModified = rawPost.dateModified

                entities.add(
                    Post(
                        rawPost.mainEntityOfPage?.id ?: uuid4().toString(),
                        tags,
                        url,
                        getPhotoUrls(posts[i]),
                        dateModified
                    )
                )
            }
        }

        return entities
    }

    private fun getPhotoUrls(post: String): List<String> {
        val urls = mutableListOf<String>()
//        println("getPhotoUrls")

        var from = post.indexOf(START_PHOTO_TAG, 0, true)
        var to = post.indexOf(FINISH_PHOTO_TAG, from, true)

        while (from != -1) {
            val url =
                if (to != -1) post.substring(from + START_PHOTO_TAG.length, to) else post.substring(
                    from + START_PHOTO_TAG.length
                )
//            println(url)
            urls.add(url)
            from = post.indexOf(START_PHOTO_TAG, from + START_PHOTO_TAG.length, true)
            to = post.indexOf(FINISH_PHOTO_TAG, from + START_PHOTO_TAG.length, true)
        }

        return urls
    }
}

@Serializable
private data class RawPost(
    var mainEntityOfPage: Entity? = null,
    val image: Image? = null,
    var headline: String = "",
    val dateModified: String = ""
)

@Serializable
private data class Image(
    val type: String,
    val url: String
)

@Serializable
private data class Entity(
    val id: String,
    var type: String
)

data class Post(
    val id: String,
    val tags: MutableList<String>,
    val url: String,
    val urls: List<String>,
    val dateModified: String
)

internal class CustomCookieStorage(private val defaultStorage: CookiesStorage) : CookiesStorage {

    override suspend fun get(requestUrl: Url): List<Cookie> {
        return defaultStorage.get(requestUrl)
    }

    override suspend fun addCookie(requestUrl: Url, cookie: Cookie) {
        defaultStorage.addCookie(requestUrl, cookie)
    }

    override fun close() {

    }
}