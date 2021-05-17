package model

import java.io.FileOutputStream
import java.io.IOException
import java.io.InputStream
import java.net.HttpURLConnection
import java.net.URL
import java.nio.file.Files
import java.nio.file.Paths


class  Model {

    private val path = Paths.get(".out")

    init { setupCache() }

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

    fun downloadImage(url: String, filename: String) {

//        val urlInputStream: InputStream = URL(url).openStream()
//        val fileOutputStream = FileOutputStream(path.resolve(filename).toFile())

        val conn: HttpURLConnection = URL(url.replace("/post", "/post/full")).openConnection() as HttpURLConnection
        conn.instanceFollowRedirects = false

        conn.inputStream.use { stream -> Files.copy(stream, path.resolve(filename)) }
    }

    private fun redirectedUrl(url: String): String {

//        println(con.responseMessage)
//        val redirectedUrl = con.getHeaderField("Location").toString()
        return url
    }
}