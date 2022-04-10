//
//  CommentInputAccesoryView.swift
//  InstaClone
//
//  Created by Ronan Mak on 18/3/2022.
//

import UIKit

// create a protocol in this file and then use a delegate once again to delegate action back to the combat controller so we can handle all that stuff

protocol CustomInputAccesoryViewDelegate: AnyObject {
    func inputView(_ inputView: CustomInputAccesoryView, wantsToUploadText text: String)
}
//NEW
enum InputViewConfiguration {
    case comments
    case messages
    
    var placeholderText: String {
        switch self {
        case .comments: return "Comment..."
        case .messages: return "Message..."
        }
    }
    
    var actionButtonTitle: String {
        switch self {
        case .comments: return "Post"
        case .messages: return "Send"
        }
    }
}

class CustomInputAccesoryView: UIView {
    
    // MARK: - Properties
    
    weak var delegate: CustomInputAccesoryViewDelegate?
    
    private let config: InputViewConfiguration
    
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
    
    init(config: InputViewConfiguration, frame: CGRect) {
        self.config = config
        super.init(frame: frame)
        
        // important
        autoresizingMask = .flexibleHeight
        backgroundColor = .white
        
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
        delegate?.inputView(self, wantsToUploadText: commentTextView.text)
    }
    
    // MARK: - Helpers
    
    func clearInputText() {
        commentTextView.text = nil
        commentTextView.placeholderLabel.isHidden = false
    }
}
