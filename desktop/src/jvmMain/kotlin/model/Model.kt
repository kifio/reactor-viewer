package model

import okhttp3.OkHttpClient
import okhttp3.Request
import java.awt.RenderingHints
import java.awt.image.BufferedImage
import java.io.IOException
import java.lang.Double.max
import java.lang.Double.min
import java.nio.file.*
import java.nio.file.attribute.BasicFileAttributes
import javax.imageio.ImageIO


class  Model {

    companion object {
        private const val SCALED_SIZE = 512.0
    }

    private val path = Paths.get(".out")
    private val client: OkHttpClient

    init {
        setupCache()
        client = OkHttpClient().newBuilder()
            .followRedirects(false)
            .followSslRedirects(false)
            .build();
    }

    private fun setupCache(): Boolean {
        return try {
            if (!Files.exists(path)) {
                Files.createDirectories(path)
            }
            true
        } catch (e: IOException) {
            e.printStackTrace()
            false
        }
    }

    fun downloadImage(url: String, filename: String, tag: String, onImageSaved: (BufferedImage) -> Unit) {
        val dst = resolvePath(filename, tag)

        if (Files.exists(dst)) {
            return
        }

        val request: Request = Request.Builder()
            .url(url)
            .build()

        client.newCall(request).execute().use { response ->
            response.body?.byteStream()?.let { stream ->
                Files.copy(stream, dst)
                getBufferedImage(dst)?.let { image ->
                    val scale = min(SCALED_SIZE / image.width, SCALED_SIZE / image.height)
                    onImageSaved(scaleBufferedImage(ImageIO.read(dst.toFile()), scale))
                }
            }
        }
    }

    fun loadCachedImages(tag: String, onImageFounded: (BufferedImage) -> Unit) {
        val cacheDir = path.resolve(tag)
        if (!Files.exists(cacheDir)) return
        Files.walkFileTree(cacheDir, object : SimpleFileVisitor<Path>() {
            @Throws(IOException::class)
            override fun visitFile(file: Path, attrs: BasicFileAttributes): FileVisitResult {
                getBufferedImage(file)?.let { image ->
                    val scale = max(SCALED_SIZE / image.width, SCALED_SIZE / image.height)
                    onImageFounded(scaleBufferedImage(ImageIO.read(file.toFile()), scale))
                }
                return FileVisitResult.CONTINUE
            }
        })
    }

    private fun resolvePath(filename: String, tag: String): Path {
        val dir = Files.createDirectories(path.resolve(tag))
        return dir.resolve(filename)
    }

    private fun getBufferedImage(path: Path,): BufferedImage? {
        var img: BufferedImage? = null
        try {
            img = ImageIO.read(path.toFile())
        } catch (e: IOException) {
            e.printStackTrace()
        }
        return img
    }

    private fun scaleBufferedImage(image: BufferedImage, scale: Double): BufferedImage {
        val scaledWidth = (image.width * scale).toInt()
        val scaledHeight = (image.height * scale).toInt()

        val resized = BufferedImage(
            scaledWidth, scaledHeight,
            image.type
        )

        val g = resized.createGraphics()
        g.setRenderingHint(
            RenderingHints.KEY_INTERPOLATION,
            RenderingHints.VALUE_INTERPOLATION_BILINEAR
        )
        g.drawImage(image, 0, 0, scaledWidth, scaledHeight, 0, 0, image.width, image.height, null)
        g.dispose()

        return resized
    }
}