//
//  ProfileController.swift
//  InstaClone
//
//  Created by Ronan Mak on 18/2/2022.
//

import UIKit

private let cellIdentifier = "ProfileCell"
private let headerIdentifier = "ProfileHeader"

class ProfileController: UICollectionViewController {
    
    // MARK: - Properties
    
    private var user: User
    private var posts = [Post]()
    
    // MARK: - Lifecycle
    
    // custom initialize. It's a dependency injection ->>>>>
    init(user: User) {
        self.user = user
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // the profile controller requires a user to populate everything that it has. the header and all the users post and stuff. It would make sense that we want to initialize this controller with a user object. So any time we want to instantiate this profileController, it's going to require that we passed in a user for it. Once the controller loads, it will already have this user and this is it up here.
    //  ->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        checkIfUserIsFollowed()
        fetchUserStats()
        fetchUserPosts()
    }
    
    // MARK: - API
    
    func checkIfUserIsFollowed() {
        UserProfileService.checkIfUserIsFollowed(userID: user.userID) { isFollowed in
//            self.fetchUserStats()
            self.user.isFollowed = isFollowed
            self.collectionView.reloadData()
        }
    }
    
    func fetchUserStats() {
        UserProfileService.fetchUserStats(userID: user.userID) { stats in
            self.user.stats = stats
            self.collectionView.reloadData()
            
            print("\(stats)")
        }
    }
    
    func fetchUserPosts() {
        PostService.fetchPosts(forUser: self.user.userID) { posts in
            self.posts = posts
            self.collectionView.reloadData()
        }
    }
    
    // MARK: - Helpers
    
    func configureCollectionView() {
        navigationItem.title = user.username
        collectionView.backgroundColor = .white
        collectionView.register(ProfileCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.register(ProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        
        let barAppearance = UINavigationBarAppearance()
        barAppearance.backgroundColor = .lightGray
        //                        barAppearance.backgroundEffect = UIBlurEffect(style: .dark)
        navigationController?.navigationBar.scrollEdgeAppearance = barAppearance
        navigationController?.navigationBar.standardAppearance = barAppearance
    }
}

// MARK: - UICollectionViewDataSource

extension ProfileController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ProfileCell
        cell.viewModel = PostViewModel(post: posts[indexPath.row])
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! ProfileHeader
        
        header.delegate = self
        header.viewModel = ProfileHeaderViewModel(user: self.user)
        
        return header
    }
    
    //    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    //        let header = collectionView.dequeueReusableSupplementary(using: headerIdentifier, for: indexPath) as! ProfileHeader
    //        return header
    //    }
}

// MARK: - UICollectionViewDelegate

extension ProfileController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
        controller.post = posts[indexPath.row]
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ProfileController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 240)
    }
}

// MARK: - ProfileHeaderDelegate

extension ProfileController: ProfileHeaderDelegate {
    func header(_ profilerHeader: ProfileHeader, didTapActionButtonFor user: User) {
        
        guard let tab = self.tabBarController as? MainTabController else { return }
        guard let currentUser = tab.user else { return }
        
        if user.isCurrentUser {
            print("shiw edit profile")
        } else if user.isFollowed {
            UserProfileService.unfollowUser(userID: user.userID) { error in
                self.user.isFollowed = false
                self.collectionView.reloadData()
                
                PostService.updateUserFeedAfterFollowing(user: user, didFollow: false)
            }
        } else {
            UserProfileService.followUser(userID: user.userID) { error in
                self.user.isFollowed = true
                self.collectionView.reloadData()
                
                NotificationService.uploadNotification(toUserID: user.userID, fromUser: currentUser, type: .follow)
                
                PostService.updateUserFeedAfterFollowing(user: user, didFollow: true)
            }
        }
    }
}
