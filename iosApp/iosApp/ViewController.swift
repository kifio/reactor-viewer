import UIKit
import app

class ViewController: UIViewController, ReactorPageHandler {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var images: UICollectionView!
    
    let reactor = Reactor()
    var storage: Storage!

    var posts = [Post]()

    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.storage = Storage(context: appDelegate.persistentContainer.viewContext)
        self.searchBar.delegate = self
        self.images.dataSource = self
        self.images.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func onPageLoaded(tag: String, page: KotlinInt?, posts: [Post]) {
        if page != nil {
            let nextPage = self.storage.savePage(page: page as! Int32, tag: tag,posts: posts)

            for post in posts {
                if !self.posts.contains(where: { p in
                    p.url == post.url
                }) {
                    self.posts.append(post)
                }
            }

            self.images.reloadData()
            if nextPage != -1 {
                self.reactor.getPage(tag: tag, page: nextPage, reactorController: self)
            }
        }
    }
}

extension ViewController : UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let query = searchBar.text {
            reactor.getLastPage(tag: query, reactorController: self)
        }
    }
}

extension ViewController : UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }

}

extension ViewController : UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = images.dequeueReusableCell(withReuseIdentifier: "imagecell", for: indexPath)

        if let imageCell = cell as? ImageCell {
            let post = posts[indexPath.row]
            imageCell.loadImage(url: post.url, completion: { [weak self] data in
                if let imageData = data {
                    self?.storage.saveImage(url: post.url, data: imageData)
                }
            })
        }

        // Configure the cell
        return cell
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return posts.count
    }

}
