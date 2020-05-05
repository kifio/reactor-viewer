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
            var paths = [IndexPath]()
            for post in posts {
                if !self.posts.contains(post.url) {
                    self.posts.append(post.url)
                    paths.append(IndexPath(item: self.posts.count - 1, section: 0))
                }
            }

            self.images.insertItems(at: paths)

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
        let cell = images.dequeueReusableCell(withReuseIdentifier: "imagecell", for: indexPath) as! ImageCell
        cell.setImage(image: nil)
        loadImage(indexPath: indexPath)
        return cell
    }

    private func loadImage(indexPath: IndexPath) {
        let urlString = self.posts[indexPath.row]

        if let data = self.storage.fetchImage(url: urlString) {
            if let cell = self.images.cellForItem(at: indexPath) as? ImageCell {
                cell.setImage(image: UIImage(data: data))
            }
        } else {
            DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 0.1, execute: { [weak self] in
                guard let strongSelf = self else { return }
                if let url = URL(string: urlString), let imageData = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        if let cell = strongSelf.images.cellForItem(at: indexPath) as? ImageCell {
                            self?.storage.saveImage(url: urlString, data: imageData)
                            cell.setImage(image: UIImage(data: imageData))
                        }
                    }
                }
            })
        }
    }
}

extension ViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let marginSpace = margin * (itemsPerRow)
        let contentWidth = self.view.frame.width - marginSpace
        let size = contentWidth / itemsPerRow
        return CGSize(width: size, height: size)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return margin / 2
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: margin / 2, left: margin / 2, bottom: margin / 2, right: margin / 2)
    }
}
