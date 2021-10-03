//
//  FWImageMemoryCache.swift
//  Freshworks_Giphy
//
//  Created by Karthik Maharajan Skandarajah on 03/10/21.
//

import Foundation

final class FWImageMemoryCache: FWImageCache {
    private lazy var cache: NSCache<NSString, NSData> = {
        let c = NSCache<NSString, NSData>()
        c.countLimit = 10
        return c
    }()
}

// MARK: - FWImageCache
extension FWImageMemoryCache {
    func getImageData(forID id: String) -> Data? {
        let idString = NSString(string: id)
        return cache.object(forKey: idString) as Data?
    }
    
    func store(imageData: Data, forID id: String) {
        let idString = NSString(string: id)
        cache.setObject(NSData(data: imageData), forKey: idString)
    }
    
    func clear() {
        cache.removeAllObjects()
    }
}
