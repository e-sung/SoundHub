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
    @IBOutlet weak var totalLikesLB: UILabel!
    @IBOutlet weak var totalComments: UILabel!
    
    static let defaultHeight:CGFloat = 500
    @IBOutlet weak var authorProfileImageBt: UIButton!
    @IBOutlet weak private var albumCoverImageView: UIImageView!
    var postInfo:Post{
        get{
            return _postInfo
        }
        set(newVal){
            _postInfo = newVal
            postTitleLB.text = newVal.title
            
            if let numLiked = newVal.num_liked { totalLikesLB.text = "\(numLiked)" }
            else { totalLikesLB.text = "0" }
            if let numComments = newVal.num_comments { totalComments.text = "\(numComments)" }
            else { totalComments.text = "0" }
            
            guard let userId = newVal.author else { return }
            NetworkController.main.fetchUser(id: userId) { (userInfo) in
                guard let userInfo = userInfo else { return }
                DispatchQueue.main.async {
                    self.authorNameLB.text = userInfo.nickname ?? ""
                    if let profileImageURL = userInfo.profileImageURL{
                        self.authorProfileImageBt.af_setImage(for: .normal, url: profileImageURL)
                    }
                }
            }

        }
    }
    private var _postInfo:Post!
}
