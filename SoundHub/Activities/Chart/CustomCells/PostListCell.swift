//
//  RankingCell.swift
//  soundHubPractice
//
//  Created by 류성두 on 2017. 11. 26..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit

class PostListCell: UITableViewCell {

    @IBOutlet weak private var postTitleLB: UILabel!
    @IBOutlet weak private var authorNameLB: UILabel!
    @IBOutlet weak private var playTimeLB: UILabel!
    @IBOutlet weak private var totalLikesLB: UILabel!
    @IBOutlet weak private var totalComments: UILabel!
    @IBOutlet weak private var authorProfileImageBt: UIButton!
    @IBOutlet weak private var albumCoverImageView: UIImageView!

    @IBAction private func onProfileButtonClickHandler(_ sender: UIButton) {
        delegate?.shouldShowProfile(of: postInfo.author)
    }

    static let defaultHeight: CGFloat = 500
    weak var delegate: PostListCellDelegate?
    var postInfo: Post {
        get { return _postInfo }
        set(newVal) {
            _postInfo = newVal
            postTitleLB.text = newVal.title

            if let numLiked = newVal.num_liked { totalLikesLB.text = "\(numLiked)" }
            else { totalLikesLB.text = "0" }
            if let numComments = newVal.num_comments { totalComments.text = "\(numComments)" }
            else { totalComments.text = "0" }
            if let authorName = newVal.author?.nickname { authorNameLB.text = authorName }
            if let albumCoverURL = newVal.albumCoverImageURL {
                albumCoverImageView.af_setImage(withURL: albumCoverURL)
            }else{
                NetworkController.main.fetchPost(id: self.postInfo.id ?? 0, completion: { (post) in
                    if let albumCoverURL = post.albumCoverImageURL {
                        self.albumCoverImageView.af_setImage(withURL: albumCoverURL)
                    }
                })
            }
            if let profileImageURL = newVal.author?.profileImageURL {
                self.authorProfileImageBt.af_setImage(for: .normal, url: profileImageURL)
            }
        }
    }
    var profileImage: UIImage {
        get { return (authorProfileImageBt.image(for: .normal) ?? #imageLiteral(resourceName: "default-profile")) }
        set (newVal) { authorProfileImageBt.setImage(newVal, for: .normal) }
    }
    var albumCoverImage: UIImage {
        get { return (albumCoverImageView.image ?? #imageLiteral(resourceName: "no_cover")) }
        set (newVal) { albumCoverImageView.image = newVal}
    }
    private var _postInfo: Post!
}

protocol PostListCellDelegate: class {
    func shouldShowProfile(of user: User?)
}
