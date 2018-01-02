//
//  PostedPostContainerCell.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 12. 15..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit
import AlamofireImage

class PostContainerCell: UICollectionViewCell {
    var posts: [Post]? {
        didSet(oldVal) {
            if oldVal != nil {
                postTB.reloadData()
            }
        }
    }
    weak var delegate: PostContainerCellDelegate?
    var firstCell: UITableViewCell!
    var lastOffset: CGFloat = 0
    var parent: FlowContainerCell!
    var headerTitle: String!
    static var headerHeight: CGFloat = 50
    var isScrolling = false
    @IBOutlet weak var postTB: UITableView!

    override func awakeFromNib() {
        postTB.delegate = self
        postTB.dataSource = self
    }
}

extension PostContainerCell: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let posts = posts else { return 1 }
        if posts.isEmpty { return 1 }
        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let posts = posts else {
            let cell = UITableViewCell(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 60))
            if indexPath == IndexPath(item: 0, section: 0) { firstCell = cell }
            return cell
        }
        if posts.isEmpty == false {
            let cell = tableView.dequeueReusableCell(withIdentifier: "postedPostCell", for: indexPath) as! PostListCell
            cell.postInfo = posts[indexPath.item]
            if indexPath == IndexPath(item: 0, section: 0) { firstCell = cell }
            cell.delegate = self
            return cell
        }else{
            let cell = UITableViewCell(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 60))
            if indexPath == IndexPath(item: 0, section: 0) { firstCell = cell }
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? PostListCell {
            cell.albumCoverImage = #imageLiteral(resourceName: "no_cover")
            cell.profileImage = #imageLiteral(resourceName: "default-profile")
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? PostListCell else { return }
        guard let post = posts?[indexPath.item] else { return }
        cell.postInfo = post
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if posts?.isEmpty == true { return 50 }
        return PostListCell.defaultHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let posts = posts else { return }
        if posts.isEmpty == true { return }
        delegate?.shouldGoTo(post: posts[indexPath.item])
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView.generateHeaderView(with: headerTitle, and: Int(PostContainerCell.headerHeight))
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return PostContainerCell.headerHeight
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        isScrolling = true
        if lastOffset > scrollView.contentOffset.y {
            if postTB.visibleCells.contains(firstCell) {
                postTB.isScrollEnabled = false
                parent.parent.mainTV.scrollToRow(at: IndexPath(item: 0,section: 0), at: .top, animated: true)
            }
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView) {
        isScrolling = false
    }

}

extension PostContainerCell {
    var isScrollEnabled: Bool {
        get {
            return postTB.isScrollEnabled
        }set(newVal) {
            return postTB.isScrollEnabled = newVal
        }
    }
    func scrollToTopWith(animation: Bool) {
        postTB.scrollToRow(at: IndexPath(item: 0,section: 0), at: .top, animated: animation)
    }
}

extension PostContainerCell: PostListCellDelegate {
    func shouldShowProfile(of user: User?) {
        self.delegate?.shouldShowProfile(of: user)
    }
}

protocol PostContainerCellDelegate: class {
    func shouldGoTo(post: Post)
    func shouldShowProfile(of user: User?)
    var isScrollEnabled: Bool { get set }
}
