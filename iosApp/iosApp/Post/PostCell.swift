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

    public func setImage(url: URL?,  imageReadyCompletion: @escaping () -> Void) {
        self.postImage.layer.masksToBounds = true
        guard let imageUrl = url else {
            self.postImage.image = nil
            return
        }

        KingfisherManager.shared.retrieveImage(with: imageUrl) { [weak self] result in
            do {
                let image = try result.get().image
                let scale = UIScreen.main.bounds.width / image.size.width
                let targetSize = CGSize(width: UIScreen.main.bounds.width, height: scale * image.size.height)
                self?.postImage.image = image.resize(targetSize: targetSize)
                imageReadyCompletion()
            } catch let err {
                print(err)
                self?.postImage.image = nil
            }
        }
    }
}

public extension UIImage {
    func resize(targetSize: CGSize, retina: Bool = true) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(
            targetSize,false,1.0
        )
        defer { UIGraphicsEndImageContext() }

        self.draw(in: CGRect(origin: .zero, size: targetSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
