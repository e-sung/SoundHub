//
//  PostedPostContainerCell.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 12. 15..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit

class PostContainerCell: UICollectionViewCell, UITableViewDelegate, UITableViewDataSource {
    var posts:[Post]?
    var headerTitle = ""
    let headerHeight = 60
    var delegate:PostContainerCellDelegate?
    @IBOutlet weak var postTB: UITableView!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let posts = posts else { return 0 }
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postedPostCell", for: indexPath) as! PostListCell
        guard let posts = posts else { return cell }
        cell.postInfo = posts[indexPath.item]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return PostListCell.defaultHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let posts = posts else { return }
        delegate?.shouldGoTo(post: posts[indexPath.item])
    }
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return CGFloat(headerHeight)
//    }
//    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        return UIView.generateHeaderView(with: headerTitle, and: headerHeight)
//    }
    
    override func awakeFromNib() {
        postTB.delegate = self
        postTB.dataSource = self
       
    }
}

protocol PostContainerCellDelegate {
    func shouldGoTo(post:Post) -> Void
}
