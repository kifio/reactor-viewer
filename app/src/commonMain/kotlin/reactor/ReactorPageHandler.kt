package reactor

interface ReactorPageHandler {
    fun onPageLoaded(page: Int?, posts: List<Post>)
}