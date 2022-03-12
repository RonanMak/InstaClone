//
//  UploadPostController.swift
//  InstaClone
//
//  Created by Ronan Mak on 12/3/2022.
//

import Foundation
import UIKit

class UploadPostController: UIViewController {
    
    // MARK: - Properties
    
    private let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "nightView")
        return imageView
    }()
    
    // textView doesn't have a placeholder
    
    private let captionTextView: InputTextView = {
        let textView = InputTextView()
        textView.placeholderLabel.text = "Enter caption..."
        textView.font = UIFont.systemFont(ofSize: 16)
        return textView
    }()
    
    private let characterCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "0/100"
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Actions
    
    @objc func didTapCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func didTapDone() {
        print("share post")
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .white
        
        navigationItem.title = "Upload Post"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(didTapCancel))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Share",
            style: .done,
            target: self,
            action: #selector(didTapDone))
        
        view.addSubview(photoImageView)
        photoImageView.setDimensions(height: 180, width: 180)
        photoImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 30)
        photoImageView.centerX(inView: view)
        photoImageView.layer.cornerRadius = 10
        
        view.addSubview(captionTextView)
        captionTextView.anchor(
            top: photoImageView.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 30,
            paddingLeft: 12,
            paddingRight: 12,
            height: 64)
        
        view.addSubview(characterCountLabel)
        characterCountLabel.anchor(
            bottom: captionTextView.bottomAnchor,
            right: view.rightAnchor,
            paddingRight: 12)
    }
}
