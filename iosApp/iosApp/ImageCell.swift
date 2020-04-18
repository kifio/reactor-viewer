//
//  ImageCell.swift
//  iosApp
//
//  Created by Ivan Murashov on 16.04.20.
//

import UIKit

class ImageCell: UICollectionViewCell {

    @IBOutlet weak var image: UIImageView!

    var url: String? = nil

    public func setImage(image: UIImage?) {
        self.image.image = image
    }

    override func prepareForReuse(){
        super.prepareForReuse()
//        self.url = nil
        self.image.image = nil
    }
}
