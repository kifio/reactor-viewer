package reactor

interface ReactorPageHandler {
    fun onPageLoaded(tag: String, page: Int?, posts: List<Post>)
}