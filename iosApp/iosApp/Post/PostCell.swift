//
//  PostCell.swift
//  iosApp
//
//  Created by Ivan Murashov on 26.06.20.
//

import UIKit
import Kingfisher

class PostCell: UITableViewCell {

    @IBOutlet weak var postImage: UIImageView!

    override func prepareForReuse() {
        super.prepareForReuse()
        self.postImage.image = nil
    }
}
