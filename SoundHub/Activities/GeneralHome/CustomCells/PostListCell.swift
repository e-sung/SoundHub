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
    @IBOutlet weak private var authorProfileImageView: UIImageView!
    @IBOutlet weak private var albumCoverImageView: UIImageView!
    var postInfo:Post{
        get{
            return _postInfo
        }
        set(newVal){
            _postInfo = newVal
            postTitleLB.text = newVal.title
            authorNameLB.text = newVal.author
            totalLikesLB.text = "\(newVal.num_liked)"
            totalComments.text = "\(newVal.num_comments)"
        }
    }
    private var _postInfo:Post!
}
