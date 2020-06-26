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

    private var imageProcessor: ImageProcessor? = nil

    public func setImage(url: URL?) {
        if url == nil {
            self.image.image = nil
        } else {

            if self.imageProcessor == nil {
                let scale = UIScreen.main.scale
                let frameSize = self.image.frame.size
                let imageSize = CGSize(width: frameSize.width * scale, height: frameSize.height * scale)
                self.imageProcessor = ResizingImageProcessor(
                referenceSize: imageSize)
            }

            guard let imageProcessor = imageProcessor else {
                self.image.image = nil
                return
            }

            self.image.kf.setImage(
                with: url,
                placeholder: UIImage(named: "placeholderImage"),
                options: [
                    .processor(imageProcessor),
                    .transition(.none),
                    .cacheOriginalImage
            ])
        }
    }
}
