import kotlin.test.Test
import kotlin.test.assertTrue

open class ReactorTest {

    private val reactor = Reactor()

    @Test
    fun testGetLastPage() {
        val tag = "комиксы"
        val parsedContent = reactor.getLastPage(tag)
        assertTrue { parsedContent.first != null }
        assertTrue { parsedContent.second.isEmpty() }
        println("Success")
    }
}