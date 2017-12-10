//
//  DetailHeaderCell.swift
//  soundHubPractice
//
//  Created by 류성두 on 2017. 11. 26..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit

class DetailHeaderCell: UITableViewCell {

    @IBOutlet weak private var authorProfileImage: UIImageView!
    @IBOutlet weak private var postTitleLB: UILabel!
    @IBOutlet weak private var authorNameLB: UILabel!
    @IBOutlet weak private var numberOfLikesLB: UILabel!
    @IBOutlet weak private var numberOfComments: UILabel!
    @IBAction func likeButtonHandler(_ sender: UIButton) {
        NetworkController.main.sendLikeRequest(on: _postInfo.id) { (newLikeCount) in
            DispatchQueue.main.async { self.numberOfLikesLB.text = "\(newLikeCount)" }
        }
    }
    
    
    var postInfo:Post{
        get{
            return _postInfo
        }
        set(newVal){
            _postInfo = newVal
            postTitleLB.text = newVal.title
            authorNameLB.text = newVal.author.nickname
            numberOfLikesLB.text = "\(newVal.num_liked)"
            numberOfComments.text = "\(newVal.num_comments)"
        }
    }
    private var _postInfo:Post!
}
