//
//  FWGifTableViewCell.swift
//  Freshworks_Giphy
//
//  Created by Karthik Maharajan Skandarajah on 03/10/21.
//

import UIKit

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
    }
    
    func hideLoading() {
        activityIndicatorView?.removeFromSuperview()
        activityIndicatorView = nil
    }
}
