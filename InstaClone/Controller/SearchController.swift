//
//  SearchController.swift
//  InstaClone
//
//  Created by Ronan Mak on 18/2/2022.
//

import UIKit

private let reuseIdentifier = "UserCell"
private let postCellIdentifier = "PostCell"

enum UserFilterConfig: Equatable {
    case followers(String)
    case following(String)
    case likes(String)
    case messages
    case all
    
    var navigationItemTitle: String {
        switch self {
        case .followers: return "Followers"
        case .following: return "Following"
        case .likes: return "Likes"
        case .messages: return "New Message"
        case .all: return "Search"
        }
    }
}

protocol SearchControllerDelegate: AnyObject {
    func controller(_ controller: SearchController, wantsToStartChatWith user: User)
}

class SearchController: UIViewController {
    
    // MARK: - Properties
    
    private let config: UserFilterConfig
    private var users = [User]()
    weak var delegate: SearchControllerDelegate?
    private var filteredUsers = [User]()
    private var posts = [Post]()
    private let searchController = UISearchController(searchResultsController: nil)
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.alwaysBounceVertical = true
        cv.backgroundColor = .white
        cv.register(ProfileCell.self, forCellWithReuseIdentifier: postCellIdentifier)
        return cv
    }()
    
    private let tableView = UITableView()
    
    private var inSearchMode: Bool {
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }
    
    // MARK: - Lifecycle
    
    init(config: UserFilterConfig) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchController()
        configureUI()
        fetchUsers()
        fetchPosts()
    }
    
    // MARK: - API
    
    func fetchPosts() {
        PostService.fetchPosts { posts in
            self.posts = posts
            self.collectionView.reloadData()
        }
    }
    
    func fetchUsers() {
        UserService.fetchUsers(forConfig: config) { users in
            self.users = users
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .white
        tableView.register(UserCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 64
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
        tableView.fillSuperview()
        navigationItem.title = config.navigationItemTitle
        tableView.isHidden = config == .all
        
        guard config == .all else { return }
        view.addSubview(collectionView)
        collectionView.fillSuperview()
    }
    
    func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        definesPresentationContext = false
    }
}

// MARK: - UITableViewDataSource

extension SearchController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inSearchMode ? filteredUsers.count : users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! UserCell
        
        let user = inSearchMode ? filteredUsers[indexPath.row] : users[indexPath.row]
        cell.viewModel = UserCellViewModel(user: user)
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension SearchController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if config == .messages {
            delegate?.controller(self, wantsToStartChatWith: users[indexPath.row])
        } else {
            let user = inSearchMode ? filteredUsers[indexPath.row] : users[indexPath.row]
            let controller = ProfileController(user: user)
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

// MARK: - UISearchResultsUpdating

extension SearchController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else { return }
        
        filteredUsers = users.filter({
            $0.username.contains(searchText) || $0.fullname.lowercased().contains(searchText)
        })
        
        self.tableView.reloadData()
    }
}

// MARK: - UISearchBarDelegate

extension SearchController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        
        guard config == .all else { return }
        collectionView.isHidden = true
        tableView.isHidden = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.showsCancelButton = false
        searchBar.text = nil
        
        tableView.reloadData()
        
        guard config == .all else { return }
        collectionView.isHidden = false
        tableView.isHidden = true
    }
}

// MARK: - UICollectionViewDataSource

extension SearchController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: postCellIdentifier, for: indexPath) as! ProfileCell
        cell.viewModel = PostViewModel(post: posts[indexPath.row])
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension SearchController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
        controller.post = posts[indexPath.row]
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension SearchController: UICollectionViewDelegateFlowLayout {
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
}

