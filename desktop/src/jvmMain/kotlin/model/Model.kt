package model

import okhttp3.OkHttpClient
import okhttp3.Request
import java.awt.image.BufferedImage
import java.io.File
import java.io.IOException
import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.Paths
import javax.imageio.ImageIO


class  Model {

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

    fun downloadImage(url: String, filename: String, tag: String,  onImageSaved: (BufferedImage) -> Unit) {
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
                getBufferedImage(dst)?.let(onImageSaved)
            }
        }
    }

    private fun resolvePath(filename: String, tag: String): Path {
        val dir = Files.createDirectories(path.resolve(tag))
        return dir.resolve(filename)
    }

    private fun getBufferedImage(path: Path): BufferedImage? {
        var img: BufferedImage? = null
        try {
            img = ImageIO.read(path.toFile())
        } catch (e: IOException) {
            e.printStackTrace()
        }
        return img
    }
}