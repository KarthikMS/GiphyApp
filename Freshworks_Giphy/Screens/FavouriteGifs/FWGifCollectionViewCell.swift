//
//  FWGifCollectionViewCell.swift
//  Freshworks_Giphy
//
//  Created by Karthik Maharajan Skandarajah on 06/10/21.
//

import UIKit

protocol FWGifCollectionViewCellDelegate: AnyObject {
    func toggleIsFavourite(gifItemID: String)
}

final class FWGifCollectionViewCell: UICollectionViewCell {
    // MARK: - Views
    lazy var gifImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleToFill
        iv.animationDuration = 1
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var favouriteButton: UIButton = {
        let b = UIButton()
        b.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        b.addTarget(self, action: #selector(favouriteButtonTapped), for: .touchUpInside)
        b.tintColor = .white
        b.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            b.widthAnchor.constraint(equalToConstant: 22),
            b.heightAnchor.constraint(equalTo: b.widthAnchor)
        ])
        
        return b
    }()
    
    // MARK: - Properties
    weak var delegate: FWGifCollectionViewCellDelegate?
    var gifItemID: String?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        gifImageView.stopAnimating()
        gifImageView.animationImages = []
        gifItemID = nil
    }
}

// MARK: - Setup
private extension FWGifCollectionViewCell {
    func addSubviews() {
        contentView.addSubview(gifImageView)
        NSLayoutConstraint.activate([
            gifImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            gifImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            gifImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            gifImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        ])
        
        contentView.addSubview(favouriteButton)
        NSLayoutConstraint.activate([
            favouriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            favouriteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10)
        ])
    }
}

// MARK: - Actions
private extension FWGifCollectionViewCell {
    @objc func favouriteButtonTapped() {
        guard let gifItemID = gifItemID else { return }
        delegate?.toggleIsFavourite(gifItemID: gifItemID)
    }
}
