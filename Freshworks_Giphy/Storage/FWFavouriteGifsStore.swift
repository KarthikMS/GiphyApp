//
//  FWFavouriteGifsStore.swift
//  Freshworks_Giphy
//
//  Created by Karthik Maharajan Skandarajah on 04/10/21.
//

import Foundation

final class FWFavouriteGifsStore {
    private var fileManager: FileManager { FileManager.default }
    
    private var favDirURL: URL {
        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent("Favourites")
    }
    
    private func getImageDataURL(forID id: String) -> URL {
        favDirURL.appendingPathComponent("\(id).png")
    }
    
    func setIsFavourite(_ isFavourite: Bool, gifItemID: String, imageData: Data, completion: (() -> Void)) {
        if isFavourite {
            addToStore(gifItemID: gifItemID, imageData: imageData, completion: completion)
        } else {
            removeFromStore(gifItemID: gifItemID, completion: completion)
        }
    }
    
    private func addToStore(gifItemID: String, imageData: Data, completion: (() -> Void) = {}) {
        try? fileManager.createDirectory(at: favDirURL, withIntermediateDirectories: false, attributes: nil)
        
        let imageDataURL = getImageDataURL(forID: gifItemID)
        do {
            try imageData.write(to: imageDataURL)
            completion()
        } catch {
            print("Unable to Write Fav Image Data to Disk: \(error.localizedDescription)")
        }
    }
    
    private func removeFromStore(gifItemID: String, completion: (() -> Void) = {}) {
        let imageDataURL = getImageDataURL(forID: gifItemID)
        do {
            try fileManager.removeItem(at: imageDataURL)
            completion()
        } catch {
            print("Unable to Remove Fav Image Data from Disk: \(error.localizedDescription)")
        }
    }
}
