package presenter

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import model.Model
import reactor.Post
import reactor.Reactor
import reactor.ReactorPageHandler
import view.View
import java.awt.image.BufferedImage
import java.io.InputStream
import javax.imageio.ImageIO

// TODO: добавить работу с кэшом: по умолчанию рисовать закэшированнеы картинки
// TODO: добавить открытие полной картинки в отдельном окне по клику
class Presenter(private var view: View?) : ReactorPageHandler {

    private var imageSize = 0
    private val reactor = Reactor()
    private val imageLoadingScope = CoroutineScope(Dispatchers.IO)
    private val model = Model()

    override fun onPageLoaded(tag: String, page: Int?, posts: List<Post>) {
        println("load page: $page in tag: $tag")
        if (page != null) loadNextPage(tag, page)
        for (post in posts) {
            imageLoadingScope.launch {
                post.urls.forEachIndexed { index, url ->
                    val filename = "${post.id.replace("/", "")}$index.jpeg"
                    model.downloadImage(url, filename, tag) { image ->
                        view?.update(image)
                    }
                }
            }
        }
    }

    fun setupCellSize(size: Int) {
        imageSize = size
        view?.setupCellSize(size)
    }

    fun makeSearch(query: String) = reactor.getLastPage(query, this)

    private fun loadNextPage(query: String, page: Int) = reactor.getPage(query, page - 1, this)
}