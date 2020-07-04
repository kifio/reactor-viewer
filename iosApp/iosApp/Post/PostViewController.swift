//
//  PostViewController.swift
//  iosApp
//
//  Created by Ivan Murashov on 26.06.20.
//

import UIKit
import Kingfisher

class PostViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var postImages: UITableView!

    private var images: [UIImage?]? = nil

    private var postId: String!
    private weak var storage: Storage? = nil

    func setup(postId: String, storage: Storage) {
        self.postId = postId
        self.storage = storage
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.postImages.dataSource = self
        self.postImages.delegate = self
        self.postImages.estimatedRowHeight = 300
        self.postImages.rowHeight = UITableViewAutomaticDimension
        self.storage?.fetchImagesUrls(for: postId, completion: { urls in
            self.images = urls.map { url in nil }
            for i in urls.indices {
                loadImage(url: URL(string: urls[i]), imageReadyCompletion: { image in
                    self.images?[i]  = image
                    self.postImages.beginUpdates()
                    self.postImages.reloadRows(
                        at: [IndexPath(item: i, section: 0)],
                        with: .automatic)
                    self.postImages.endUpdates()
                })
            }

            self.postImages.reloadData()
            self.storage = nil
        })
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        images?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = postImages.dequeueReusableCell(withIdentifier: "postImageCell", for: indexPath) as! PostCell
        if let images = self.images {
            cell.postImage.image = images[indexPath.row]
        }
        return cell
    }

    public func loadImage(url: URL?, imageReadyCompletion: @escaping(UIImage?) -> Void) {

        guard let imageUrl = url else {
            return
        }

        KingfisherManager.shared.retrieveImage(with: imageUrl) { [weak self] result in
            do {
                let image = try result.get().image
                let scale = UIScreen.main.bounds.width / image.size.width
                let targetSize = CGSize(width: UIScreen.main.bounds.width, height: scale * image.size.height)
                DispatchQueue.global(qos: .utility).async {
                    let resizedImage = image.resize(targetSize: targetSize)
                    DispatchQueue.main.async {
                        imageReadyCompletion(resizedImage)
                    }
                }
            } catch let err {
                print(err)
            }
        }
    }
}

private extension UIImage {
    func resize(targetSize: CGSize, retina: Bool = true) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(
            targetSize, false, 1.0
        )
        defer {
            UIGraphicsEndImageContext()
        }

        self.draw(in: CGRect(origin: .zero, size: targetSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

