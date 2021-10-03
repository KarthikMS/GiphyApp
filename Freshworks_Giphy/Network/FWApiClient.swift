//
//  FWApiClient.swift
//  Freshworks_Giphy
//
//  Created by Karthik Maharajan Skandarajah on 03/10/21.
//

import Foundation

class FWApiClient {
    func getTrendingGifs(offset: Int, completion: @escaping ([FWGiphyItem]) -> Void) -> URLSessionDataTask? {
        guard var urlComponents = URLComponents(string: "https://api.giphy.com/v1/gifs/trending") else { return nil }
        urlComponents.queryItems = [
            URLQueryItem(name: "api_key", value: "ztOIgXf080gisfb4wNDXhg7SimzFj6AD"),
            URLQueryItem(name: "limit", value: "\(Constants.API.GifFetchLimit)"),
            URLQueryItem(name: "offset", value: "\(offset)")
        ]
        guard let url = urlComponents.url else { return nil }
        print("DEBUG :: APIClient :: fetching trending gifs. offset: \(offset)")

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil else {
                print("API Response Error: \(error!.localizedDescription)")
                return
            }
            guard let data = data else { return }
            
            guard let responseObject = try? JSONDecoder().decode(FWGiphyItemsAPIResponse.self, from: data) else {
                print("error")
                return
            }
            
            completion(responseObject.data)
        }
        task.resume()
        
        return task
    }
    
    func searchGifs(query: String) {
        guard var urlComponents = URLComponents(string: "https://api.giphy.com/v1/gifs/search") else { return }
        urlComponents.queryItems = [
            URLQueryItem(name: "api_key", value: "ztOIgXf080gisfb4wNDXhg7SimzFj6AD"),
            URLQueryItem(name: "q", value: query)
        ]
        guard let url = urlComponents.url else { return }

        print("DEBUG :: APIClient :: Search gifs. query: \(query)")
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil else {
                print("API Response Error: \(error?.localizedDescription)")
                return
            }
            guard let data = data else { return }
            
            guard let responseObject = try? JSONDecoder().decode(FWGiphyItemsAPIResponse.self, from: data) else {
                print("error")
                return
            }
            
            // TODO
        }
        .resume()
    }
}
