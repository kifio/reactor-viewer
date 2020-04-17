import UIKit
import app

class ViewController: UIViewController, ReactorPageHandler {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var images: UICollectionView!

    private let itemsPerRow: CGFloat = 3
    private let margin: CGFloat = 8.0

    let reactor = Reactor()
    var storage: Storage!
    var posts = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.storage = Storage(context: appDelegate.persistentContainer.viewContext)
        self.searchBar.delegate = self
        self.images.dataSource = self
        self.images.delegate = self
    }

    func onPageLoaded(tag: String, page: KotlinInt?, posts: [Post]) {
        if page != nil {
            let nextPage = self.storage.savePage(page: page as! Int32, tag: tag.lowercased() ,posts: posts)

            for post in posts {
                if !self.posts.contains(where: { url in
                    url == post.url
                }) {
                    self.posts.append(post.url)
                }
            }

            self.images.reloadData()

            if nextPage != -1 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.reactor.getPage(tag: tag, page: nextPage, reactorController: self)
                }
            }
        }
    }
}

extension ViewController : UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let query = searchBar.text {
            reactor.getLastPage(tag: query, reactorController: self)
            storage.fetchPosts(tag: query.lowercased(), completion: {
                self.posts.append(contentsOf: $0)
                self.images.reloadData()
            })
        }
    }
}

extension ViewController : UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }

}

extension ViewController : UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = images.dequeueReusableCell(withReuseIdentifier: "imagecell", for: indexPath)
        if let imageCell = cell as? ImageCell {
            let url = posts[indexPath.row]
            imageCell.url = url
            self.loadImage(urlString: url, cell: imageCell, completion: { data in
                if let imageData = data {
                    imageCell.setImage(data: imageData)
                }
            })
        }
        return cell
    }

    private func loadImage(urlString: String, cell: ImageCell, completion: @escaping (Data?) -> Void) {
        if let url = URL(string: urlString) {
            let data = self.storage.fetchImage(url: urlString)
            DispatchQueue.global(qos: .background).async { [weak self] in
                do {
                    if data != nil {
                        DispatchQueue.main.async {
                            if url.absoluteString == cell.url {
                                completion(data)
                            }
                        }
                    } else {
                        let imageData = try Data(contentsOf: url)
                        DispatchQueue.main.async {
                            self?.storage.saveImage(url: urlString, data: imageData)
                            if url.absoluteString == cell.url {
                                completion(imageData)
                            }
                        }
                    }
                } catch {
                    print("Cannot dowmload image")
                    DispatchQueue.main.async {
                        if url.absoluteString == cell.url {
                            completion(nil)
                        }
                    }
                }
            }
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

extension ViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let marginSpace = margin * (itemsPerRow + 1)
        let contentWidth = self.view.frame.width - marginSpace
        let size = contentWidth / 3
        return CGSize(width: size, height: size)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return margin
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
    }
}
