//
//  ImageCell.swift
//  iosApp
//
//  Created by Ivan Murashov on 16.04.20.
//

import UIKit

class ImageCell: UICollectionViewCell {

    @IBOutlet weak var image: UIImageView!

    private var url: String? = nil

    public func loadImage(url: String, completion: @escaping (Data?) -> Void) {
        self.url = String(url)
        if let url = URL(string: url) {
            DispatchQueue.global(qos: .background).async { [weak self] in
                do {
                    let data = try Data(contentsOf: url)
                    DispatchQueue.main.async {
                        completion(data)
                        if url.absoluteString == self?.url {
                            self?.image.image = UIImage(data: data)
                        }
                    }
                } catch {
                    print("Cannot dowmload image")
                }
            }
        }
    }
}
