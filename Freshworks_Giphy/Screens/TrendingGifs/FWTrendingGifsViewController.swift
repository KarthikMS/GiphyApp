//
//  FWTrendingGifsViewController.swift
//  Freshworks_Giphy
//
//  Created by Karthik Maharajan Skandarajah on 03/10/21.
//

import UIKit

final class FWTrendingGifsViewController: UIViewController {
    // MARK: - Views
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.register(FWGifTableViewCell.self, forCellReuseIdentifier: "cell")
        tv.dataSource = self
        tv.delegate = self
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
}

// MARK: - Setup
private extension FWTrendingGifsViewController {
    func addSubviews() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
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
        let gifItem = viewModel.tableViewItems[indexPath.row]
//        cell.textLabel?.text = "\(indexPath.row): \(gifItem.title)"
//        cell.showLoading()
        viewModel.configure(cell: cell, at: indexPath)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension FWTrendingGifsViewController: UITableViewDelegate {
    
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
}
