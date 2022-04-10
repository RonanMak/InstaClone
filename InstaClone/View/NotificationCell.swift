//
//  NotificationCell.swift
//  InstaClone
//
//  Created by Ronan Mak on 24/3/2022.
//

import UIKit

protocol NotificationCellDelegate: AnyObject {
    func cell(_ cell: NotificationCell, wantsToFollow userID: String)
    func cell(_ cell: NotificationCell, wantsToUnfollow userID: String)
    func cell(_ cell: NotificationCell, wantsToViewPost postID: String)
}

class NotificationCell: UITableViewCell {
    
    // MARK: - Properties
    
    var viewModel: NotificationViewModel? {
        didSet { configure() }
    }
    
    weak var delegate: NotificationCellDelegate?
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        //        imageView.image = #imageLiteral(resourceName: "nightView")
        return imageView
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    private let postImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        //NEW
        let tap = UITapGestureRecognizer(target: self, action: #selector(handlePostTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tap)
        
        return imageView
    }()
    
    private lazy var followButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 3
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 0.5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(handleFollowTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        addSubview(profileImageView)
        profileImageView.setDimensions(height: 48, width: 48)
        profileImageView.layer.cornerRadius = 48 / 2
        profileImageView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
        
        contentView.addSubview(followButton)
        followButton.centerY(inView: self)
        followButton.anchor(right: rightAnchor, paddingRight: 12, width: 84, height: 32)
        
        contentView.addSubview(postImageView)
        postImageView.centerY(inView: self)
        postImageView.anchor(right: rightAnchor, paddingRight: 12, width: 40, height: 40)
        
        contentView.addSubview(infoLabel)
        infoLabel.centerY(inView: profileImageView, leftAnchor: profileImageView.rightAnchor, paddingLeft: 8)
        infoLabel.anchor(right: followButton.leftAnchor, paddingRight: 4)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    @objc func handleFollowTapped() {
        guard let viewModel = viewModel else { return }
        
        if viewModel.notification.userIsFollowed {
            delegate?.cell(self, wantsToUnfollow: viewModel.notification.userID)
        } else {
            delegate?.cell(self, wantsToFollow: viewModel.notification.userID)
        }
    }
    
    @objc func handlePostTapped() {
        guard let postID = viewModel?.notification.postID else { return }
        delegate?.cell(self, wantsToViewPost: postID)
    }
    
    // MARK: - Helpers
    
    func configure() {
        guard let viewModel = viewModel else {
            return
        }

        profileImageView.sd_setImage(with: viewModel.userProfileImageUrl)
        postImageView.sd_setImage(with: viewModel.postImageUrl)
        
        infoLabel.attributedText = viewModel.notificationMessage
        
        followButton.isHidden = !viewModel.shouldHidePostImage
        postImageView.isHidden = viewModel.shouldHidePostImage
        
        followButton.setTitle(viewModel.followButtonText, for: .normal)
        followButton.backgroundColor = viewModel.followButtonBackgroundColor
        followButton.setTitleColor(viewModel.followButtonTextColor, for: .normal)
    }
}
