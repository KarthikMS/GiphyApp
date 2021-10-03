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
}

struct FWGiphyItemImage: Codable {
    let height: Int
    let width: Int
    let url: URL
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let heightString = try container.decode(String.self, forKey: .height)
        let widthString = try container.decode(String.self, forKey: .width)
        url = try container.decode(URL.self, forKey: .url)
        
        height = Int(heightString) ?? -1
        width = Int(widthString) ?? -1
    }
}
