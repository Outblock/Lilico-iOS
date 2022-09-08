//
//  ImageAnimated.swift
//  Lilico
//
//  Created by Selina on 8/9/2022.
//

import SwiftUI
import SnapKit

extension ImageAnimated {
    static func appRefreshImageNames() -> [String] {
        var images: [String] = []
        for i in 0...95 {
            images.append("refresh-header-seq-\(i)")
        }
        
        return images
    }
}

struct ImageAnimated: UIViewRepresentable {
    let imageSize: CGSize
    let imageNames: [String]
    let duration: Double
    var isAnimating: Bool = false

    func makeUIView(context: Self.Context) -> UIView {
        let containerView = UIView(frame: CGRect(x: 0, y: 0
            , width: imageSize.width, height: imageSize.height))

        let animationImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))

        animationImageView.clipsToBounds = true
        animationImageView.contentMode = UIView.ContentMode.scaleAspectFill

        animationImageView.animationImages = generateImages()
        animationImageView.animationDuration = duration

        containerView.addSubview(animationImageView)
        animationImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(imageSize.width)
            make.height.equalTo(imageSize.height)
        }

        return containerView
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<ImageAnimated>) {
        guard let imageView = uiView.subviews.first as? UIImageView else {
            return
        }
        
        if isAnimating {
            imageView.startAnimating()
        } else {
            imageView.stopAnimating()
            imageView.image = generateImages().first
        }
    }
    
    private func generateImages() -> [UIImage] {
        var images = [UIImage]()
        imageNames.forEach { imageName in
            if let img = UIImage(named: imageName) {
                images.append(img)
            }
        }
        
        return images
    }
}
