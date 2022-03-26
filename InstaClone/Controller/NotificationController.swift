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
            print("\(notifications)")
        }
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
    }
}

extension NotificationController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NotificationCell
        cell.viewModel = NotificationViewModel(notification: notifications[indexPath.row])
        cell.backgroundColor = .white
        return cell
    }
}
