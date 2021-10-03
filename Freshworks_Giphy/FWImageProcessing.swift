//
//  FWImageProcessing.swift
//  Freshworks_Giphy
//
//  Created by Karthik Maharajan Skandarajah on 03/10/21.
//

import UIKit

// https://stackoverflow.com/a/54598404
func animationImages(from gifData: Data) -> [UIImage]? {
    guard let source =  CGImageSourceCreateWithData(gifData as CFData, nil) else { return nil }
    var images = [UIImage]()
    let imageCount = CGImageSourceGetCount(source)
    for i in 0 ..< imageCount {
        if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
            images.append(UIImage(cgImage: image))
        }
    }
    return images
}
