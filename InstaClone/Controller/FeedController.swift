//
//  FeedController.swift
//  InstaClone
//
//  Created by Ronan Mak on 18/2/2022.
//

import UIKit
import Firebase

private let reuseIdentitfier = "Cell"

class FeedController: UICollectionViewController {
    
    // MARK: - Properties
    
    private var posts = [Post]() {
        didSet { collectionView.reloadData() }
    }
    
    var post: Post? {
        didSet { collectionView.reloadData() }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchPosts()
        
        if post != nil {
            checkIfUserLikedPosts()
        }
    }
    
    // MARK: - Actions
    
    @objc func handleRefresh() {
        posts.removeAll()
        fetchPosts()
    }
    //NEW
    @objc func showMessages() {
        let controller = ConversationsController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleLogout() {
        do {
            try Auth.auth().signOut()
            let controller = LoginController()
            controller.delegate = self.tabBarController as? MainTabController
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        } catch {
            print("DEBUG: failed to sign out")
        }
    }
    
    // MARK: - API
    
    func fetchPosts() {
        guard post == nil else { return }
        //        PostService.fetchPosts { posts in
        //            self.posts = posts
        //            self.collectionView.refreshControl?.endRefreshing()
        //            self.checkIfUserLikedPosts()
        //        }
        PostService.fetchFeedPosts { posts in
            self.posts = posts
            self.collectionView.refreshControl?.endRefreshing()
            self.checkIfUserLikedPosts()
        }
    }
    
    func checkIfUserLikedPosts() {
        if let post = post {
            PostService.checkIfUserLikedPost(post: post) { didLike in
                self.post?.didLike = didLike
            }
        } else {
            posts.forEach { post in
                PostService.checkIfUserLikedPost(post: post) { didLike in
                    if let index = self.posts.firstIndex(where: { $0.postID == post.postID }) {
                        self.posts[index].didLike = didLike
                    }
                }
            }
        }
    }
    
    func deletePost(_ post: Post) {
        self.showLoader(true)
        
        PostService.deletePost(post.postID) { _ in
            self.showLoader(false)
            self.handleRefresh()
        }
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        
        let barAppearance = UINavigationBarAppearance()
        barAppearance.backgroundColor = .white
        //                        barAppearance.backgroundEffect = UIBlurEffect(style: .dark)
        navigationController?.navigationBar.scrollEdgeAppearance = barAppearance
        navigationController?.navigationBar.standardAppearance = barAppearance
        
        collectionView.backgroundColor = .white
        //        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentitfier)
        collectionView.register(FeedCell.self, forCellWithReuseIdentifier: reuseIdentitfier)
        
        navigationItem.title = "Feed"
        
        if self.post == nil {
            
            let refresher = UIRefreshControl()
            
            refresher.addTarget(
                self,
                action: #selector(handleRefresh),
                for: .valueChanged)
            collectionView.refreshControl = refresher
            
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                title: "Logout",
                style: .plain,
                target: self,
                action: #selector(handleLogout))
            //NEW
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: #imageLiteral(resourceName: "send2"),
                style: .plain,
                target: self,
                action: #selector(showMessages))
        }
    }
}

// MARK: - UICollectionViewDataSource

extension FeedController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return post == nil ? self.posts.count : 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentitfier, for: indexPath) as! FeedCell
        
        cell.delegate = self
        
        if let post = post {
            cell.viewModel = PostViewModel(post: post)
        } else {
            if !posts.isEmpty {
                cell.viewModel = PostViewModel(post: posts[indexPath.row])
            }
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension FeedController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = view.frame.width
        var height = width + 8 + 40 + 8
        height += 50
        height += 60
        return CGSize(width: width, height: height)
    }
}

// MARK: - FeedCellDelegate

extension FeedController: FeedCellDelegate {
    //NEW
    func cell(_ cell: FeedCell, wantsToViewLikesFor postId: String) {
        let controller = SearchController(config: .likes(postId))
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func didTapIconButton(_ cell: FeedCell, wantsToShowProfileFor ownerID: String) {
        UserProfileService.fetchUser(withUserID: ownerID) { user in
            let controller = ProfileController(user: user)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    //NEW
    func cell(_ cell: FeedCell, wantsToShowOptionsForPost post: Post) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let editPostAction = UIAlertAction(title: "Edit Post", style: .default) { _ in
            print("DEBUG: Edit post")
        }
        
        let deletePostAction = UIAlertAction(title: "Delete Post", style: .destructive) { _ in
            self.deletePost(post)
        }
        
        let unfollowAction = UIAlertAction(title: "Unfollow", style: .default) { _ in
            self.showLoader(true)
            UserProfileService.unfollowUser(userID: post.ownerUserID) { _ in
                self.showLoader(false)
            }
        }
        
        let followAction = UIAlertAction(title: "Follow", style: .default) { _ in
            self.showLoader(true)
            UserProfileService.followUser(userID: post.ownerUserID) { _ in
                self.showLoader(false)
            }
        }
        
        let cancelAction =  UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        if post.ownerUserID == Auth.auth().currentUser?.uid {
            alert.addAction(editPostAction)
            alert.addAction(deletePostAction)
        } else {
            UserProfileService.checkIfUserIsFollowed(userID: post.ownerUserID) { isFollowed in
                if isFollowed {
                    alert.addAction(unfollowAction)
                } else {
                    alert.addAction(followAction)
                }
            }
        }
        
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func cell(_ cell: FeedCell, wantsToShowCommentsFor post: Post) {
        let controller = CommentController(post: post)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(_ cell: FeedCell, didLike post: Post) {
        
        guard let tab = self.tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        //NEW
        guard let ownerUid = cell.viewModel?.post.ownerUserID else { return }
        
        cell.viewModel?.post.didLike.toggle()
        
        if post.didLike {
            PostService.unlikePost(post: post) { _ in
                cell.likeButton.setImage(#imageLiteral(resourceName: "like_unselected"), for: .normal)
                cell.likeButton.tintColor = .black
                cell.viewModel?.post.likes = post.likes - 1
                
                NotificationService.deleteNotification(toUid: ownerUid, type: .like,
                                                       postId: cell.viewModel?.post.postID)
            }
        } else {
            PostService.likePost(post: post) { _ in
                cell.likeButton.setImage(#imageLiteral(resourceName: "like_selected"), for: .normal)
                cell.likeButton.tintColor = .red
                cell.viewModel?.post.likes = post.likes + 1
                
                NotificationService.uploadNotification(toUserID: post.ownerUserID,
                                                       fromUser: user,
                                                       type: .like,
                                                       post: post)
            }
        }
    }
}
