//
//  ProfileCell.swift
//  InstaClone
//
//  Created by Ronan Mak on 22/2/2022.
//

import UIKit
import SDWebImage

class ProfileCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var viewModel: PostViewModel? {
        didSet { configure() }
    }
    
    //NEW
    var photoImageView: UIImage? {
        didSet { postImageView.image = photoImageView }
    }
    
    private let postImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.image = UIImage(named: "NewYork")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .lightGray
        
        addSubview(postImageView)
        postImageView.fillSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    func configure() {
        guard let viewModel = viewModel else { return }
        
        postImageView.sd_setImage(with: viewModel.imageUrl)
       
    }
}
