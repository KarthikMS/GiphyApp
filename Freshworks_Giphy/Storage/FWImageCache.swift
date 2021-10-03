//
//  FWImageCache.swift
//  Freshworks_Giphy
//
//  Created by Karthik Maharajan Skandarajah on 03/10/21.
//

import Foundation

protocol FWImageCache {
    func getImageData(forID id: String) -> Data?
    func store(imageData: Data, forID id: String)
    func clear()
}
