//
//  FWPaginator.swift
//  Freshworks_Giphy
//
//  Created by Karthik Maharajan Skandarajah on 03/10/21.
//

import Foundation

final class FWPaginator {
    private let apiClient: FWApiClient
    private var currentOffset = 0
    private var isFetchingNextPage = false
    private var currentTask: URLSessionDataTask?
    
    init(apiClient: FWApiClient = FWApiClient()) {
        self.apiClient = apiClient
    }
    
    func startFromFirstPage(completion: @escaping ([FWGiphyItem]) -> Void) {
        currentTask?.cancel()
        currentOffset = 0
        isFetchingNextPage = false
        getNextPage(completion: completion)
    }
    
    func getNextPage(completion: @escaping ([FWGiphyItem]) -> Void) {
        guard !isFetchingNextPage else { return }
        isFetchingNextPage = true
        
        print("DEBUG :: Paginator :: Fetching next page. currentOffset: \(currentOffset)")
        
        currentTask = apiClient.getTrendingGifs(offset: currentOffset) { [weak self] items in
            guard let self = self else { return }
            completion(items)
            
            self.currentOffset += Constants.API.GifFetchLimit
            self.isFetchingNextPage = false
            self.currentTask = nil
        }
    }
}
