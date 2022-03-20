//
//  CommentController.swift
//  InstaClone
//
//  Created by Ronan Mak on 18/3/2022.
//

import UIKit

private let reuseIdentifier = "CommentCell"

class CommentController: UICollectionViewController {
    
    // MARK: - Properties
    
    private let post: Post
    private var comments = [Comment]()
    
    private lazy var commentInputView: CommentInputAccesoryView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let commentView = CommentInputAccesoryView(frame: frame)
        commentView.delegate = self
        return commentView
    }()
    
    // MARK: - Lifecycle
    
    init(post: Post) {
        self.post = post
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        fetchComments()
    }
    
    override var inputAccessoryView: UIView? {
        get { return commentInputView }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // viewWillAppear gets called every time the view is about to appear on screen
    override func viewWillAppear(_ animated: Bool) {
        print("willapear")
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("willdisapear")
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - API
    
    func fetchComments() {
        CommentService.fetchComment(forPost: post.postID) { comments in
            self.comments = comments
            self.collectionView.reloadData()
        }
    }
    
    // MARK: - Helper
    
    func configureCollectionView() {
        navigationItem.title = "Comments"
        
        collectionView.backgroundColor = .white
        collectionView.register(CommentCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
    }
}

// MARK: - UICollectionViewDataSource

extension CommentController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CommentCell
        
        cell.viewModel = CommentViewModel(comment: comments[indexPath.row])
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CommentController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let viewModel = CommentViewModel(comment: comments[indexPath.row])
        let height = viewModel.size(forWidth: view.frame.width).height + 32
        
        return CGSize(width: view.frame.width, height: height)
    }
}

// MARK: - CommentInputAccesoryViewDelegate

extension CommentController: CommentInputAccesoryViewDelegate {
    func inputView(_ inputView: CommentInputAccesoryView, wantsToUploadComment comment: String) {
        
        guard let tab = self.tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        
        self.showLoader(true)

        CommentService.uploadComment(comment: comment, postID: post.postID, user: user) { error in
            self.showLoader(false)
            inputView.clearCommentTextView()
        }
    }
}
