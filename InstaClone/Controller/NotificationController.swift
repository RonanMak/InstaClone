//
//  NotificationController.swift
//  InstaClone
//
//  Created by Ronan Mak on 18/2/2022.
//

import UIKit

private let reuseIdentifier = "NotificationCell"

class NotificationController: UITableViewController {
    
    // MARK: - Properties
    
    private var notifications = [Notification]() {
        didSet { tableView.reloadData() }
    }
    
    private var refresher = UIRefreshControl()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .green
        configureTableView()
        fetchNotification()
    }
    
    // MARK: - API
    func fetchNotification() {
        NotificationService.fetchNotifications { notifications in
            self.notifications = notifications
            self.checkIfuserIsFollowed()
        }
    }
    
    func checkIfuserIsFollowed() {
        notifications.forEach { notification in
            
            guard notification.type == .follow else { return }
            
            UserProfileService.checkIfUserIsFollowed(userID: notification.userID) { isFollowed in
                if let index = self.notifications.firstIndex(where: { $0.userID == notification.userID }) {
                    self.notifications[index].userIsFollowed = isFollowed
                }
            }
        }
    }
    
    // MARK: - Actions
    
    @objc func handleRefresh() {
        notifications.removeAll()
        fetchNotification()
        refresher.endRefreshing()
    }
    
    // MARK: - Helpers
    
    func configureTableView() {
        
        let barAppearance = UINavigationBarAppearance()
        barAppearance.backgroundColor = .lightGray
        barAppearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        
        //                        barAppearance.backgroundEffect = UIBlurEffect(style: .dark)
        navigationController?.navigationBar.scrollEdgeAppearance = barAppearance
        navigationController?.navigationBar.standardAppearance = barAppearance
        
        view.backgroundColor = .white
        navigationItem.title = "Notifications"
        navigationItem.titleView?.tintColor = .black
        
        tableView.register(NotificationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
        
        refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refresher
    }
}

// MARK: - UITableViewDataSource

extension NotificationController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NotificationCell
        cell.viewModel = NotificationViewModel(notification: notifications[indexPath.row])
        cell.delegate = self
        cell.backgroundColor = .white
        return cell
    }
}

// MARK: - UITableViewDelegate

extension NotificationController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let userID = notifications[indexPath.row].userID
        showLoader(true)
        UserProfileService.fetchUser(withUserID: notifications[indexPath.row].userID) { user in
            self.showLoader(false)
            
            let controller = ProfileController(user: user)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

// MARK: - NotificationCellDelegate

extension NotificationController: NotificationCellDelegate {
    func cell(_ cell: NotificationCell, wantsToFollow userID: String) {
        showLoader(true)
        
        UserProfileService.followUser(userID: userID) { _ in
            self.showLoader(false)
            
            cell.viewModel?.notification.userIsFollowed.toggle()
        }
    }
    
    func cell(_ cell: NotificationCell, wantsToUnfollow userID: String) {
        showLoader(true)
        
        UserProfileService.unfollowUser(userID: userID) { _ in
            self.showLoader(false)
            
            cell.viewModel?.notification.userIsFollowed.toggle()
            print("unfollow user here")
        }
    }
    
    func cell(_ cell: NotificationCell, wantsToViewPost postID: String) {
        showLoader(true)
        
        PostService.fetchPost(withPostID: postID) { post in
            self.showLoader(false)
            
            let controller = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
            controller.post = post
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}
