/**
 * Публичный апи парсера.
 */
class Reactor {

    fun getLastPage(tag: String): Pair<Int?, List<Post>> {
        return Pair(0, emptyList())
    }

    fun getPage(page: Int): List<Post>{
        return emptyList()
    }

    /**
     * @param imageUrl - url картинки в посте
     * @param tag - tag по которому делался поиск
     */
    data class Post(val imageUrl: String, val tag: String)
}