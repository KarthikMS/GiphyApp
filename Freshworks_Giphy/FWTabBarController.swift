//
//  FWTabBarController.swift
//  Freshworks_Giphy
//
//  Created by Karthik Maharajan Skandarajah on 03/10/21.
//

import UIKit

final class FWTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTabBarAppearance()
        configureTabBarItems()
    }
}

// MARK: - Setup
private extension FWTabBarController {
    func configureTabBarAppearance() {
        guard #available(iOS 15.0, *) else { return }

        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        tabBar.isTranslucent = true
        tabBar.scrollEdgeAppearance = appearance
        tabBar.standardAppearance = appearance
    }
    
    func configureTabBarItems() {
        let trendingItem = UITabBarItem()
        trendingItem.image = UIImage(systemName: "photo.fill.on.rectangle.fill")
        let trendingVC = FWTrendingGifsViewController()
        trendingVC.tabBarItem = trendingItem
        
        let favoritesItem = UITabBarItem()
        favoritesItem.image = UIImage(systemName: "heart.fill")
        let favouritesVC = FWFavouriteGifsViewController()
        favouritesVC.tabBarItem = favoritesItem
        
        viewControllers = [trendingVC, favouritesVC]
    }
}

