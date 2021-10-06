//
//  FWFavouriteGifsStore.swift
//  Freshworks_Giphy
//
//  Created by Karthik Maharajan Skandarajah on 04/10/21.
//

import Foundation

final class FWFavouriteGifsStore {
    private var fileManager: FileManager { FileManager.default }
    
    func getAllFavouriteGifs() -> [FWGiphyItem] {
        guard let contents = try? fileManager.contentsOfDirectory(atPath: gifsDirURL.path) else { return [] }
        let decoder = JSONDecoder()
        var gifItems = [FWGiphyItem]()
        
        for gifId in contents {
            let gifDataURL = getGifDataURL(forID: gifId)
            guard let gifData = fileManager.contents(atPath: gifDataURL.path),
                  let gifItem = try? decoder.decode(FWGiphyItem.self, from: gifData) else { continue }
            
            gifItems.append(gifItem)
        }
        
        return gifItems
    }
    
    func setIsFavourite(_ isFavourite: Bool, gifItem: FWGiphyItem, imageData: Data, completion: (() -> Void)) {
        if isFavourite {
            addToStore(gifItem: gifItem, imageData: imageData, completion: completion)
        } else {
            removeFromStore(gifItemID: gifItem.id, completion: completion)
        }
    }
    
    private func addToStore(gifItem: FWGiphyItem, imageData: Data, completion: (() -> Void) = {}) {
        try? fileManager.createDirectory(at: gifsDirURL, withIntermediateDirectories: true, attributes: nil)
        try? fileManager.createDirectory(at: imagesDirURL, withIntermediateDirectories: true, attributes: nil)
        
        let gifDataURL = getGifDataURL(forID: gifItem.id)
        let imageDataURL = getImageDataURL(forID: gifItem.id)
        do {
            // Saving imageData
            try imageData.write(to: imageDataURL)
            
            // Saving gif data
            let encodedGifData = try JSONEncoder().encode(gifItem)
            try encodedGifData.write(to: gifDataURL)
            
            completion()
        } catch {
            print("Unable to Write Fav Image Data to Disk: \(error)")
        }
    }
    
    private func removeFromStore(gifItemID: String, completion: (() -> Void) = {}) {
        let gifDataURL = getGifDataURL(forID: gifItemID)
        let imageDataURL = getImageDataURL(forID: gifItemID)
        
        do {
            try fileManager.removeItem(at: gifDataURL)
            try fileManager.removeItem(at: imageDataURL)
            completion()
        } catch {
            print("Unable to Remove Fav Image Data from Disk: \(error)")
        }
    }
}

// MARK: - Base URLs
private extension FWFavouriteGifsStore {
    var favDirURL: URL {
        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent("Favourites")
    }
    
    var imagesDirURL: URL {
        favDirURL.appendingPathComponent("ImageData")
    }
    
    var gifsDirURL: URL {
        favDirURL.appendingPathComponent("GIFs")
    }
}

// MARK: - GIF Item specific URLs
private extension FWFavouriteGifsStore {
    func getImageDataURL(forID id: String) -> URL {
        imagesDirURL.appendingPathComponent("\(id).png")
    }
    
    func getGifDataURL(forID id: String) -> URL {
        gifsDirURL.appendingPathComponent("\(id)")//".dat")
    }
}
