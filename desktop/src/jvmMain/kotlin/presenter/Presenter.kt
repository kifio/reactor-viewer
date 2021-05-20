package presenter

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import model.Model
import reactor.Post
import reactor.Reactor
import reactor.ReactorPageHandler
import view.View
import java.awt.image.BufferedImage


class Presenter(private var view: View?) : ReactorPageHandler {

    private var imageSize = 0
    private val reactor = Reactor()
    private val imageLoadingScope = CoroutineScope(Dispatchers.IO)
    private val cacheScope = CoroutineScope(Dispatchers.IO)
    private val model = Model()
    private var currentTag: String? = null

    override fun onPageLoaded(tag: String, page: Int?, posts: List<Post>) {
        if (currentTag != tag) { return }
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

    fun makeSearch(query: String) {
        currentTag = query
        view?.clear()
        reactor.getLastPage(query, this)
        cacheScope.launch {
            model.loadCachedImages(query) { image ->
                view?.update(image)
            }
        }
    }

    fun handleListItemClick(image: BufferedImage) {
        view?.showImageInDialog(image)
    }

    private fun loadNextPage(query: String, page: Int) {
        if (page > 0) {
            reactor.getPage(query, page - 1, this)
        }
    }
}