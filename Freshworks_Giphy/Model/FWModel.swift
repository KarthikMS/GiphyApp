//
//  FWModel.swift
//  Freshworks_Giphy
//
//  Created by Karthik Maharajan Skandarajah on 03/10/21.
//

import Foundation

struct FWGiphyItemsAPIResponse: Codable {
    let data: [FWGiphyItem]
}

struct FWGiphyItem: Codable {
    let id: String
    let title: String
    let images: FWGiphyItemImages
}

struct FWGiphyItemImages: Codable {
    let original: FWGiphyItemImage
    let downsized: FWGiphyItemImage
    let fixedHeightDownsampled: FWGiphyItemImage
    
    enum CodingKeys: String, CodingKey {
        case original
        case downsized
        case fixedHeightDownsampled = "fixed_height_downsampled"
    }
}

struct FWGiphyItemImage: Codable {
    let height: Int
    let width: Int
    let url: URL
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // height
        if let height = try? container.decodeIfPresent(Int.self, forKey: .height) {
            self.height = height
        } else {
            let heightString = try container.decode(String.self, forKey: .height)
            height = Int(heightString) ?? -1
        }
        
        // width
        if let width = try? container.decodeIfPresent(Int.self, forKey: .width) {
            self.width = width
        } else {
            let widthString = try container.decode(String.self, forKey: .width)
            width = Int(widthString) ?? -1
        }
        
        url = try container.decode(URL.self, forKey: .url)
    }
}
