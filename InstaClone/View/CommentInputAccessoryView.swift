//
//  CommentInputAccessoryView.swift
//  InstaClone
//
//  Created by Ronan Mak on 18/3/2022.
//

import UIKit

class CommentInputAccessoryView: UIView {
    
    // MARK: - Properties
    
    private let commentTextView: InputTextView = {
       let textView = InputTextView()
        textView.placeholderText = "Enter comment.."
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.isScrollEnabled = false
        textView.placeholderShouldCenter = true
        return textView
    }()
    
    private let postButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Post", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handlePostTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // important
        autoresizingMask = .flexibleHeight
        
        addSubview(postButton)
        postButton.anchor(top: topAnchor, right: rightAnchor, paddingRight: 8)
        postButton.setDimensions(height: 50, width: 50)
        
        addSubview(commentTextView)
        commentTextView.anchor(top: topAnchor,
                               left: leftAnchor,
                               bottom: safeAreaLayoutGuide.bottomAnchor,
                               right: postButton.leftAnchor,
                               paddingTop: 8,
                               paddingLeft: 8,
                               paddingBottom: 0,
                               paddingRight: 8)
        
        let divider = UIView()
        divider.backgroundColor = .lightGray
        addSubview(divider)
        divider.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, height: 0.5)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // this will figure out the size based on the view, the dimensions of the view components inside the view
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    // MARK: - Actions
    
    @objc func handlePostTapped() {
         
    }
}
