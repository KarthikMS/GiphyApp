//
//  FWFavouriteGifsViewController.swift
//  Freshworks_Giphy
//
//  Created by Karthik Maharajan Skandarajah on 03/10/21.
//

import UIKit

private extension FWFavouriteGifsViewController {
    enum DisplayStyle: Int {
        case grid
        case list
    }
}

final class FWFavouriteGifsViewController: UIViewController {
    // MARK: - Subviews
    private lazy var segmentControl: UISegmentedControl = {
        let s = UISegmentedControl()
        s.insertSegment(withTitle: "Grid", at: 0, animated: false)
        s.insertSegment(withTitle: "List", at: 1, animated: false)
        s.selectedSegmentIndex = 0
        s.addTarget(self, action: #selector(segmentControlValueChanged), for: .valueChanged)
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    
    private lazy var collectionView: UICollectionView = {
        let l = UICollectionViewFlowLayout()
        l.scrollDirection = .vertical
        l.minimumInteritemSpacing = 10
        
        let c = UICollectionView(frame: .zero, collectionViewLayout: l)
        
        c.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        c.dataSource = self
        c.delegate = self
        c.translatesAutoresizingMaskIntoConstraints = false
        return c
    }()
    
    // MARK: - Properties
    private let viewModel = FWFavouriteGifsViewModel()
    private var displayStyle: DisplayStyle = .grid
}

// MARK: - View Life Cycle
extension FWFavouriteGifsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addSubviews()
    }
}

// MARK: - Setup
private extension FWFavouriteGifsViewController {
    func addSubviews() {
        view.addSubview(segmentControl)
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            segmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            segmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            segmentControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            
            collectionView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }
}

// MARK: - Actions
private extension FWFavouriteGifsViewController {
    @objc func segmentControlValueChanged() {
        displayStyle = DisplayStyle(rawValue: segmentControl.selectedSegmentIndex) ?? .grid
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource
extension FWFavouriteGifsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        30
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .red
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension FWFavouriteGifsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch displayStyle {
        case .grid:
            
            let width: CGFloat = {
                let smallWidth = (collectionView.frame.width - (2 * 10)) / 3 - 1
                
                if (indexPath.row % 5 == 0) || (indexPath.row % 5 == 1) || (indexPath.row % 5 == 2) {
                    return smallWidth
                } else {
                    let largeWidth = (2 * smallWidth) + 10
                    let shouldUseLargeWidth = (indexPath.row % 10 == 3) || (indexPath.row % 10 == 9)
                    
                    if shouldUseLargeWidth {
                        return largeWidth
                    } else {
                        return smallWidth
                    }
                }
            }()
            return CGSize(width: width, height: 150)
            
        case .list:
            return CGSize(width: collectionView.frame.width, height: 200)
        }
    }
}
