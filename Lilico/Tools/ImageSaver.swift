//
//  ImageSaver.swift
//  Lilico
//
//  Created by cat on 2022/6/11.
//

import Foundation
import UIKit

class ImageSaver: NSObject {
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }

    @objc func saveCompleted(_: UIImage, didFinishSavingWithError error: Error?, contextInfo _: UnsafeRawPointer) {
        if error != nil {
            print("Save Image Error: \(String(describing: error))")
        } else {
            print("Save finished!")
        }
    }
}
