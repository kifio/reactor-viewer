import io.ktor.client.request.get
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.withContext
import reactor.*
import kotlin.test.Test
import kotlin.test.assertTrue

open class ReactorTest {

    private val reactor = Reactor()

    @Test
    fun testGetLastPage() = runBlocking {
        val html = client.get<String>("${Reactor.BASE_URL}/комиксы")
        val tags = html.split("<span class='current'>")
        var page: Int? = null

        for (i in 1 until tags.size) {
            page = tags[i].substring(0, tags[i].indexOf("</span>")).toIntOrNull()
            if (page != null) {
                val posts = reactor.parseHtml(html)
                assertTrue { posts.isNotEmpty() }
            }
        }
    }

    @Test
    fun testGetSpecificPage() = runBlocking {
        var page = 6949
        while (page > 6000) {
            val html = client.get<String>("${Reactor.BASE_URL}/комиксы/$page")
            val posts = reactor.parseHtml(html)
            assertTrue { posts.isNotEmpty() }
            page--
            Thread.sleep(500)
        }
    }
}