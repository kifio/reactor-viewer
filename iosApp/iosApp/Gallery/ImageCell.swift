//
//  ImageCell.swift
//  iosApp
//
//  Created by Ivan Murashov on 16.04.20.
//

import UIKit
import Kingfisher

class ImageCell: UICollectionViewCell {

    @IBOutlet weak var image: UIImageView!

    override func prepareForReuse() {
        super.prepareForReuse()
        self.image.image = nil
    }
}
