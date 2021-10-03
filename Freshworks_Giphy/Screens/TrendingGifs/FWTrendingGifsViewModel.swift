//
//  FWTrendingGifsViewModel.swift
//  Freshworks_Giphy
//
//  Created by Karthik Maharajan Skandarajah on 03/10/21.
//

import Foundation

protocol FWTrendingGifsViewModelDelegate: AnyObject {
    func reloadTableView()
    func reloadTableViewRows(at indexPaths: [IndexPath])
}

final class FWTrendingGifsViewModel {
    // MARK: - Properties
    private let paginator: FWPaginator
    private let imageMemoryCache: FWImageMemoryCache
    private let imageDiskCache: FWImageDiskCache
    private let favGifsStore: FWFavouriteGifsStore
    
    private(set) var tableViewItems = [FWGiphyItem]()
    weak var delegate: FWTrendingGifsViewModelDelegate?
    private var favouriteGifs = Set<String>()
    
    // MARK: - Init
    init() {
        self.paginator = FWPaginator()
        self.imageMemoryCache = FWImageMemoryCache()
        self.imageDiskCache = FWImageDiskCache()
        self.favGifsStore = FWFavouriteGifsStore()
    }
}

// MARK: - Cell
extension FWTrendingGifsViewModel {
    func configure(cell: FWGifTableViewCell, at indexPath: IndexPath) {
        guard indexPath.row < tableViewItems.count else { return }
        let gifItem = tableViewItems[indexPath.row]
        
        cell.delegate = self
        cell.gifItemID = gifItem.id
        cell.isFavourite = favouriteGifs.contains(gifItem.id)
        
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
        else {
            print("DEBUG :: FWTrendingGifsViewModel :: Fetching gif image: \(gifItem.title) index: \(indexPath.row)")
            cell.showLoading()
            
            fetchGIFImageData(url: gifItem.images.fixedHeightDownsampled.url) { [weak self] gifImageData in
                let animationImages = animationImages(from: gifImageData)
                DispatchQueue.main.async {
                    cell.hideLoading()
                    cell.gifImageView.animationImages = animationImages
                    cell.gifImageView.startAnimating()
                }
                DispatchQueue.global(qos: .background).async { [weak self] in
                    self?.imageMemoryCache.store(imageData: gifImageData, forID: gifItem.id)
                    self?.imageDiskCache.store(imageData: gifImageData, forID: gifItem.id)
                }
            }
        }
    }
}

// MARK: - Fetching
extension FWTrendingGifsViewModel {
    func fetchFirstPage() {
        paginator.startFromFirstPage { [weak self] gifItems in
            DispatchQueue.main.async {
                self?.tableViewItems = gifItems
                self?.delegate?.reloadTableView()
            }
        }
    }
    
    func fetchNextPage() {
        paginator.getNextPage { [weak self] gifItems in
            DispatchQueue.main.async {
                self?.tableViewItems.append(contentsOf: gifItems)
                self?.delegate?.reloadTableView()
            }
        }
    }
}

// MARK: - Networking
private extension FWTrendingGifsViewModel {
    func fetchGIFImageData(url: URL, completion: @escaping (Data) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil else {
                return
            }
            guard let data = data else {
                return
            }
            completion(data)
        }.resume()
    }
}

// MARK: - FWGifTableViewCellDelegate
extension FWTrendingGifsViewModel: FWGifTableViewCellDelegate {
    func toggleIsFavourite(gifItemID: String) {
        guard let itemInfo = tableViewItems.enumerated().first(where: { $1.id == gifItemID }) else { return }
        let rowIndex = itemInfo.0
        let gifItem = itemInfo.1
        
        var imageData = imageMemoryCache.getImageData(forID: gifItem.id)
        if imageData == nil {
            imageData = imageDiskCache.getImageData(forID: gifItem.id)
        }
        guard let imageData = imageData else { return }
        
        let wasFavourite = favouriteGifs.contains(gifItemID)
        let isFavourite = !wasFavourite
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.favGifsStore.setIsFavourite(isFavourite, gifItemID: gifItemID, imageData: imageData) {
                DispatchQueue.main.async {
                    if isFavourite {
                        self.favouriteGifs.insert(gifItemID)
                    } else {
                        self.favouriteGifs.remove(gifItemID)
                    }
                    self.delegate?.reloadTableViewRows(at: [IndexPath(row: rowIndex, section: 0)])
                }
            }
        }
    }
}
