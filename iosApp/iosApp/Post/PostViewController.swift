//
//  PostViewController.swift
//  iosApp
//
//  Created by Ivan Murashov on 26.06.20.
//

import UIKit

class PostViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var postImages: UITableView!

    private var urls = [String]()
    private var postId: String!
    private weak var storage: Storage? = nil

    func setup(postId: String,
               storage: Storage) {
        self.postId = postId
        self.storage = storage
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.postImages.dataSource = self
        self.postImages.delegate = self
        self.postImages.rowHeight = UITableViewAutomaticDimension
        self.postImages.estimatedRowHeight = 300
        self.storage?.fetchImagesUrls(for: postId, completion: { images in
            self.urls.append(contentsOf: images)
            self.postImages.reloadData()
            self.storage = nil
        })
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return urls.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = postImages.dequeueReusableCell(withIdentifier: "postImageCell", for: indexPath) as! PostCell
        let urlString = self.urls[indexPath.row]
        self.postImages.beginUpdates()
        cell.setImage(url: URL(string: urlString)) {
            self.postImages.endUpdates()
        }
        return cell
    }

//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
//
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
}
