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

class Presenter(private var view: View?) : ReactorPageHandler {

    private var imageSize = 0
    private val reactor = Reactor()
    private val imageLoadingScope = CoroutineScope(Dispatchers.IO)
    private val model = Model()

    override fun onPageLoaded(tag: String, page: Int?, posts: List<Post>) {
//        if (page != null) loadNextPage(tag, page)
        for (post in posts) {
            imageLoadingScope.launch {
                post.urls.forEachIndexed { index, url ->
                    model.downloadImage(url, "${post.id.replace("/", "")}$index")
                }
            }
        }
//        view?.update()
    }

    fun setupCellSize(size: Int) {
        imageSize = size
        view?.setupCellSize(size)
    }

    fun makeSearch(query: String) = reactor.getLastPage(query, this)

    private fun loadNextPage(query: String, page: Int) = reactor.getPage(query, page - 1, this)

    private fun decodeImage(inputStream: InputStream): BufferedImage {
        val src: BufferedImage = ImageIO.read(inputStream)
        // TODO: Scale and crop buffered image. Maybe better to do it with image loading library.
        return src
    }
}