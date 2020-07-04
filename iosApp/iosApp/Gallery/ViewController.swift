import UIKit
import app

class ViewController: UIViewController, ReactorPageHandler {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var images: UICollectionView!

    private let itemsPerRow: CGFloat = 3
    private let margin: CGFloat = 4.0
    private let delay = 0.5

    var currentTag: String? = nil
    let reactor = Reactor()
    var storage: Storage!
    var posts = [PostEntity]()
    var wasLastPostShown = true

    override func viewDidLoad() {
        super.viewDidLoad()
        if let navigationController = self.navigationController {
            navigationController.interactivePopGestureRecognizer?.delegate = self
            navigationController.setNavigationBarHidden(true, animated: false)
        }

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.storage = Storage(context: appDelegate.persistentContainer.viewContext)
        self.searchBar.delegate = self
        self.images.dataSource = self
        self.images.delegate = self


        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
        layout.minimumLineSpacing = margin
        layout.minimumInteritemSpacing = margin
        self.images.collectionViewLayout = layout
    }

    func onPageLoaded(tag: String, page: KotlinInt?, posts: [Post]) {
        if page != nil {
            let nextPage = self.storage.savePage(page: page as! Int32, tag: tag.lowercased() ,posts: posts)

            if wasLastPostShown {
                wasLastPostShown = false
            }

            refreshCollectionView(tag)

            if nextPage != -1 && currentTag == tag {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    self.reactor.getPage(tag: tag, page: nextPage, reactorController: self)
                }
            }
        }
    }
}

extension ViewController : UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let query = searchBar.text {
            searchBar.resignFirstResponder()
            self.posts.removeAll()
            self.images.reloadData()
            self.currentTag = query
            reactor.getLastPage(tag: query, reactorController: self)
            refreshCollectionView(query)
        }
    }
}

extension ViewController : UICollectionViewDataSource {

    func refreshCollectionView(_ query: String) {
        let oldestPostDate = self.posts.isEmpty ? nil : self.posts.last?.date
        storage.fetchPosts(tag: query.lowercased(), laterThen: oldestPostDate, completion: { posts in
            var paths = [IndexPath]()
            for post in posts {
                self.posts.append(post)
                paths.append(IndexPath(row: self.posts.count - 1, section: 0))
            }

            self.images?.performBatchUpdates({
                self.images.insertItems(at: paths)
            }, completion: nil)
        })
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = images.dequeueReusableCell(withReuseIdentifier: "imagecell", for: indexPath) as! ImageCell
        if indexPath.row == posts.count - 1 {
            self.wasLastPostShown = true
        }

        let index = indexPath.row
        if let urlString = self.posts[index].url {
            cell.setImage(url: URL(string: urlString))
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "postvc") as! PostViewController
        if let id = self.posts[indexPath.row].id {
            vc.setup(postId: id, storage: storage)
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalSpacing = (2 * self.margin) + ((self.itemsPerRow - 1) * self.margin)
        let width = (self.images.bounds.width - totalSpacing) / self.itemsPerRow
        return CGSize(width: width, height: width)
    }
}

extension ViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {

    }
}

// MARK: - UIGestureRecognizerDelegate

extension ViewController: UIGestureRecognizerDelegate {

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let navigationController = self.navigationController,
         gestureRecognizer == navigationController.interactivePopGestureRecognizer else {
            return true
        }
        return navigationController.viewControllers.count > 1
    }
}
