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

    public func setImage(url: URL?) {
        if url == nil {
            self.image.image = nil
        } else {
            self.image.kf.setImage(
                with: url,
                placeholder: UIImage(named: "placeholderImage"),
                options: [
                    .processor(DownsamplingImageProcessor(size: image.bounds.size)),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.none),
                    .cacheOriginalImage
            ])
        }
    }
}
