//
//  FWTrendingGifsViewModel.swift
//  Freshworks_Giphy
//
//  Created by Karthik Maharajan Skandarajah on 03/10/21.
//

import Foundation
import UIKit

protocol FWTrendingGifsViewModelDelegate: AnyObject {
    func reloadTableView()
    func reloadTableViewRows(at indexPaths: [IndexPath])
}

private extension FWTrendingGifsViewModel {
    enum ListType {
        case trendingGifs
        case searchResults
    }
}

final class FWTrendingGifsViewModel: NSObject {
    // MARK: - Dependencies
    private let apiClient: FWApiClient
    private let paginator: FWPaginator
    private let imageMemoryCache: FWImageMemoryCache
    private let imageDiskCache: FWImageDiskCache
    private let favGifsStore: FWFavouriteGifsStore
    private lazy var throttler = FWThrottler(throttleDelay: 0.3, throttleQueue: .main)
    
    // MARK: - Properties
    weak var delegate: FWTrendingGifsViewModelDelegate?
    private var listType: ListType = .trendingGifs
    private var trendingGifs = [FWGiphyItem]()
    private var searchResults = [FWGiphyItem]()
    var tableViewItems: [FWGiphyItem] {
        switch listType {
        case .trendingGifs: return trendingGifs
        case .searchResults: return searchResults
        }
    }
    private var favouriteGifs = Set<String>()
    
    // MARK: - Init
    init(apiClient: FWApiClient = FWApiClient()) {
        self.apiClient = apiClient
        self.paginator = FWPaginator(apiClient: apiClient)
        self.imageMemoryCache = FWImageMemoryCache()
        self.imageDiskCache = FWImageDiskCache()
        self.favGifsStore = FWFavouriteGifsStore()
        super.init()
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
                self?.trendingGifs = gifItems
                self?.delegate?.reloadTableView()
            }
        }
    }
    
    func fetchNextPage() {
        paginator.getNextPage { [weak self] gifItems in
            DispatchQueue.main.async {
                self?.trendingGifs.append(contentsOf: gifItems)
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

// MARK: - UISearchBarDelegate
extension FWTrendingGifsViewModel: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        throttler.throttle { [weak self] in
            if searchText.isEmpty {
                self?.listType = .trendingGifs
                self?.delegate?.reloadTableView()
            } else {
                self?.apiClient.searchGifs(query: searchText) { [weak self] gifItems in
                    DispatchQueue.main.async {
                        self?.listType = .searchResults
                        self?.searchResults = gifItems
                        self?.delegate?.reloadTableView()
                    }
                }
            }
        }
        
    }
}
