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
    
    private var posts = [Post]()
    
    var post: Post?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        fetchPosts()
    }
    
    // MARK: - Actions
    
    @objc func handleRefresh() {
        posts.removeAll()
        fetchPosts()
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
            print("DEBUG: fauled to sign out")
        }
    }
    
    // MARK: - API
    
    func fetchPosts() {
        guard post == nil else { return }
        PostService.fetchPosts { posts in
            self.posts = posts
            
            print("did fetch posts")
            self.collectionView.refreshControl?.endRefreshing()
            self.collectionView.reloadData()
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
