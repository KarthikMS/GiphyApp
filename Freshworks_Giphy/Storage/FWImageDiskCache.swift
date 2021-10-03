//
//  FWImageDiskCache.swift
//  Freshworks_Giphy
//
//  Created by Karthik Maharajan Skandarajah on 03/10/21.
//

import Foundation

final class FWImageDiskCache: FWImageCache {
    private var fileManager: FileManager { FileManager.default }
    
    private var cacheDirURL: URL {
        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent("ImageCache")
    }
    
    private func getImageDataURL(forID id: String) -> URL {
        cacheDirURL.appendingPathComponent("\(id).png")
    }
}

// MARK: - FWImageCache
extension FWImageDiskCache {
    func getImageData(forID id: String) -> Data? {
        let imageDataURL = getImageDataURL(forID: id)
        return try? Data(contentsOf: imageDataURL)
    }
    
    func store(imageData: Data, forID id: String) {
        try? fileManager.createDirectory(at: cacheDirURL, withIntermediateDirectories: false, attributes: nil)
        
        let imageDataURL = getImageDataURL(forID: id)
        do {
            try imageData.write(to: imageDataURL)
        } catch {
            print("Unable to Write Image Data to Disk: \(error.localizedDescription)")
        }
    }
    
    func clear() {
        try? fileManager.removeItem(at: cacheDirURL)
    }
}
