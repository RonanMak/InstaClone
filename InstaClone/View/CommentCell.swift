//
//  CommentCell.swift
//  InstaClone
//
//  Created by Ronan Mak on 18/3/2022.
//

import UIKit
import SDWebImage

class CommentCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var viewModel: CommentViewModel? {
        didSet { configure() }
    }
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    private let commentLabel: UILabel = {
       let label = UILabel()
        label.textColor = .black
        return label
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        profileImageView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 8)
        profileImageView.setDimensions(height: 40, width: 40)
        profileImageView.layer.cornerRadius = 40 / 2
        
        commentLabel.numberOfLines = 0
        addSubview(commentLabel)
        commentLabel.centerY(inView: profileImageView, leftAnchor: profileImageView.rightAnchor, paddingLeft: 8)
        
        commentLabel.anchor(right: rightAnchor, paddingRight: 8)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    func configure() {
        guard let viewModel = self.viewModel else { return }
        
        profileImageView.sd_setImage(with: viewModel.profileImageUrl)
        commentLabel.attributedText = viewModel.commentLabelText()
    }
}

