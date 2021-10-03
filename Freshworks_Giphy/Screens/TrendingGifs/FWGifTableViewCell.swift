//
//  FWGifTableViewCell.swift
//  Freshworks_Giphy
//
//  Created by Karthik Maharajan Skandarajah on 03/10/21.
//

import UIKit

protocol FWGifTableViewCellDelegate: AnyObject {
    func toggleIsFavourite(gifItemID: String)
}

class FWGifTableViewCell: UITableViewCell {
    // MARK: - Views
    private var activityIndicatorView: UIActivityIndicatorView?
    
    lazy var gifImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleToFill
        iv.animationDuration = 1
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var favouriteButton: UIButton = {
        let b = UIButton()
        b.setImage(UIImage(systemName: "heart"), for: .normal)
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
    weak var delegate: FWGifTableViewCellDelegate?
    var gifItemID: String?
    
    var isFavourite: Bool = false {
        didSet {
            let systemImageName = isFavourite ? "heart.fill" : "heart"
            favouriteButton.setImage(UIImage(systemName: systemImageName), for: .normal)
        }
    }
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
private extension FWGifTableViewCell {
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

// MARK: - Loading
extension FWGifTableViewCell {
    func showLoading() {
        hideLoading()
        
        let activityIndicatorView = UIActivityIndicatorView(style: .large)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(activityIndicatorView)
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
        activityIndicatorView.startAnimating()
        
        self.activityIndicatorView = activityIndicatorView
        
        favouriteButton.isHidden = true
    }
    
    func hideLoading() {
        activityIndicatorView?.removeFromSuperview()
        activityIndicatorView = nil
        
        favouriteButton.isHidden = false
    }
}

// MARK: - Actions
private extension FWGifTableViewCell {
    @objc func favouriteButtonTapped() {
        guard let gifItemID = gifItemID else { return }
        delegate?.toggleIsFavourite(gifItemID: gifItemID)
    }
}
