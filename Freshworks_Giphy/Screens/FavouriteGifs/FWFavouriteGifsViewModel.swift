//
//  FWFavouriteGifsViewModel.swift
//  Freshworks_Giphy
//
//  Created by Karthik Maharajan Skandarajah on 03/10/21.
//

import Foundation

protocol FWFavouriteGifsViewModelDelegate: AnyObject {
    func reloadCollectionView()
}

final class FWFavouriteGifsViewModel {
    // MARK: - Dependencies
    private let imageMemoryCache: FWImageMemoryCache
    private let imageDiskCache: FWImageDiskCache
    private let favGifsStore: FWFavouriteGifsStore
    
    // MARK: - Properties
    weak var delegate: FWFavouriteGifsViewModelDelegate?
    private(set) var collectionViewItems = [FWGiphyItem]()
    
    // MARK: - Init
    init() {
        self.imageMemoryCache = FWImageMemoryCache()
        self.imageDiskCache = FWImageDiskCache()
        self.favGifsStore = FWFavouriteGifsStore()
    }
}

extension FWFavouriteGifsViewModel {
    func loadFavGifs() {
        collectionViewItems = favGifsStore.getAllFavouriteGifs()
    }
    
    func configure(cell: FWGifCollectionViewCell, at indexPath: IndexPath) {
        guard indexPath.row < collectionViewItems.count else { return }
        let gifItem = collectionViewItems[indexPath.row]
        
        cell.delegate = self
        cell.gifItemID = gifItem.id
        
        if let cachedImageData = imageMemoryCache.getImageData(forID: gifItem.id) {
            cell.gifImageView.animationImages = animationImages(from: cachedImageData)
            cell.gifImageView.startAnimating()
        }
        else if let cachedImageData = imageDiskCache.getImageData(forID: gifItem.id) {
            cell.gifImageView.animationImages = animationImages(from: cachedImageData)
            cell.gifImageView.startAnimating()
            DispatchQueue.global(qos: .background).async { [weak self] in
                self?.imageMemoryCache.store(imageData: cachedImageData, forID: gifItem.id)
            }
        }
    }
}

// MARK: - FWGifCollectionViewCellDelegate
extension FWFavouriteGifsViewModel: FWGifCollectionViewCellDelegate {
    func toggleIsFavourite(gifItemID: String) {
        // Will always only be un-favourited.
        guard let itemInfo = collectionViewItems.enumerated().first(where: { $1.id == gifItemID }) else { return }
        let itemIndex = itemInfo.0
        let gifItem = itemInfo.1
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.favGifsStore.setIsFavourite(false, gifItem: gifItem, imageData: Data()) {
                DispatchQueue.main.async {
                    self.collectionViewItems.remove(at: itemIndex)
                    self.delegate?.reloadCollectionView()
                }
            }
        }
    }
}
