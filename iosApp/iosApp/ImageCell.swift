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

    public func setImage(data: Data) {
        self.image.image = UIImage(data: data)
    }

    override func prepareForReuse(){
        super.prepareForReuse()
//        self.url = nil
        self.image.image = nil
    }
}
