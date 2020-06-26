//
//  PostViewController.swift
//  iosApp
//
//  Created by Ivan Murashov on 26.06.20.
//

import UIKit

class PostViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {


    @IBOutlet weak var postImages: UITableView!

    var urls: [String]!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.postImages.dataSource = self
        self.postImages.delegate = self
        self.postImages.rowHeight = UITableViewAutomaticDimension
        self.postImages.estimatedRowHeight = 300
        // Do any additional setup after loading the view.
    }
    

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */

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
