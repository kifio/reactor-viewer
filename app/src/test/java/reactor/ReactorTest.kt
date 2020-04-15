import kotlinx.coroutines.runBlocking
import reactor.Reactor
import kotlin.test.Test
import kotlin.test.assertTrue

open class ReactorTest {

    private val reactor = Reactor()

    @Test
    fun testGetLastPage() = runBlocking {
        val tag = "комиксы"
        val parsedContent = reactor.getLastPage(tag)
        assertTrue { parsedContent.first != null }
    }
}