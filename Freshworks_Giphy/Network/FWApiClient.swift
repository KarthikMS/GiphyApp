//
//  FWApiClient.swift
//  Freshworks_Giphy
//
//  Created by Karthik Maharajan Skandarajah on 03/10/21.
//

import Foundation

class FWApiClient {
    func getTrendingGifs() {
        guard var urlComponents = URLComponents(string: "https://api.giphy.com/v1/gifs/trending") else { return }
        urlComponents.queryItems = [URLQueryItem(name: "api_key", value: "ztOIgXf080gisfb4wNDXhg7SimzFj6AD"),
                                    URLQueryItem(name: "limit", value: "1")] // delete this, no need to pass limit.
        guard let url = urlComponents.url else { return }

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
            
//            let image = responseObject.data[0].images.original
//            self.requestImage(url: image.url)
        }
        .resume()
    }
    
    func searchGifs(query: String) {
        guard var urlComponents = URLComponents(string: "https://api.giphy.com/v1/gifs/search") else { return }
        urlComponents.queryItems = [URLQueryItem(name: "api_key", value: "ztOIgXf080gisfb4wNDXhg7SimzFj6AD"),
                                    URLQueryItem(name: "q", value: query)] // delete this, no need to pass limit.
        guard let url = urlComponents.url else { return }

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
            
//            let image = responseObject.data[0].images.original
//            self.requestImage(url: image.url)
        }
        .resume()
    }
}
