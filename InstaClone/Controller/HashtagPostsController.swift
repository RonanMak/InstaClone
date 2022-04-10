//
//  HashtagPostsController.swift
//  InstaClone
//
//  Created by Ronan Mak on 9/4/2022.
//
//NEW
import UIKit

private let cellIdentifier = "PhotoCell"

class HashtagPostsController: UICollectionViewController {
    
    private var posts = [Post]()
    private let hashtag: String

    // MARK: - Lifecycle
    
    init(hashtag: String) {
        self.hashtag = hashtag
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        fetchPosts()
    }
    
    // MARK: - API
    
    func fetchPosts() {
        PostService.fetchPosts(forHashtag: hashtag) { posts in
            self.posts = posts
            self.collectionView.reloadData()
        }
    }
    
    // MARK: - Helpers
    
    func configureCollectionView() {
        navigationItem.title = "#\(hashtag)"

        collectionView.backgroundColor = .white
        collectionView.register(ProfileCell.self, forCellWithReuseIdentifier: cellIdentifier)
    }
}

// MARK: - UICollectionViewDataSource

extension HashtagPostsController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ProfileCell
        cell.viewModel = PostViewModel(post: posts[indexPath.row])
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension HashtagPostsController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
        controller.post = posts[indexPath.row]
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension HashtagPostsController: UICollectionViewDelegateFlowLayout {
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

