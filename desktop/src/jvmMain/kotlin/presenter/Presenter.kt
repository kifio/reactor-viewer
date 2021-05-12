package presenter

import view.View
import java.awt.image.BufferedImage
import java.io.InputStream
import javax.imageio.ImageIO

class Presenter(private var view: View?) {

    private var imageSize = 0

    fun setupCellSize(size: Int) {
        imageSize = size
        view?.setupCellSize(size)
    }

    fun makeSearch(query: String) {

    }

    fun loadPage(page: Int) {

    }

    private fun decodeImage(inputStream: InputStream): BufferedImage {
        val src: BufferedImage = ImageIO.read(inputStream)
        // TODO: Scale and crop buffered image. Maybe better to do it with image loading library.
        return src
    }

}