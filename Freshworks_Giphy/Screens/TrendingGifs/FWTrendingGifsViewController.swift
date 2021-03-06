//
//  FWTrendingGifsViewController.swift
//  Freshworks_Giphy
//
//  Created by Karthik Maharajan Skandarajah on 03/10/21.
//

import UIKit

final class FWTrendingGifsViewController: UIViewController {
    // MARK: - Views
    private lazy var searchBar: UISearchBar = {
        let s = UISearchBar()
        s.placeholder = "Search for GIFs"
        s.delegate = viewModel
        s.searchTextField.clearButtonMode = .whileEditing
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.register(FWGifTableViewCell.self, forCellReuseIdentifier: "cell")
        tv.dataSource = self
        tv.prefetchDataSource = self
        tv.rowHeight = 200
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.allowsSelection = false
        return tv
    }()
    
    // MARK: - Properties
    private let viewModel = FWTrendingGifsViewModel()
}

// MARK: - View Life Cycle
extension FWTrendingGifsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        viewModel.delegate = self
        addSubviews()
        viewModel.fetchFirstPage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.refreshFavouriteGifs()
    }
}

// MARK: - Setup
private extension FWTrendingGifsViewController {
    func addSubviews() {
        view.addSubview(searchBar)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - UITableViewDataSource
extension FWTrendingGifsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.tableViewItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FWGifTableViewCell
        viewModel.configure(cell: cell, at: indexPath)
        return cell
    }
}

// MARK: - UITableViewDataSourcePrefetching
extension FWTrendingGifsViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        print(indexPaths)
        let needsFetch = indexPaths.contains(where: { $0.row >= viewModel.tableViewItems.count - 1 })
        if needsFetch {
            viewModel.fetchNextPage()
        }
    }
}

// MARK: - FWTrendingGifsViewModelDelegate
extension FWTrendingGifsViewController: FWTrendingGifsViewModelDelegate {
    func reloadTableView() {
        tableView.reloadData()
    }
    
    func reloadTableViewRows(at indexPaths: [IndexPath]) {
        tableView.reloadRows(at: indexPaths, with: .automatic)
    }
}
