//
//  DetailHeaderCell.swift
//  soundHubPractice
//
//  Created by 류성두 on 2017. 11. 26..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit

class DetailHeaderCell: UITableViewCell {

    @IBOutlet weak var authorProfileImageButton: UIButton!
    @IBOutlet weak private var postTitleLB: UILabel!
    @IBOutlet weak private var authorNameLB: UILabel!
    @IBOutlet weak private var numberOfLikesLB: UILabel!
    @IBOutlet weak private var bpmLB: UILabel!
    @IBOutlet weak private var numberOfComments: UILabel!
    @IBAction func likeButtonHandler(_ sender: UIButton) {
        guard let postId = _postInfo.id else { return }
        NetworkController.main.sendLikeRequest(on: postId) { (newLikeCount) in
            NotificationCenter.default.post(name: NSNotification.Name("shouldReloadContents"), object: nil)
            self.numberOfLikesLB.text = "\(newLikeCount)"
        }
    }
    
    @IBAction func authorProfileImageButtonHandler(_ sender: UIButton) {

    }
    var postInfo:Post{
        get{ return _postInfo }
        set(newVal){
            _postInfo = newVal
            postTitleLB.text = newVal.title
            numberOfLikesLB.text = "\(newVal.num_liked ?? 0)"
            numberOfComments.text = "\(newVal.num_comments ?? 0)"
            bpmLB.text =  (newVal.bpm == nil || newVal.bpm == 0 ) ? "110" : "\(newVal.bpm!)"
            guard let authorId = newVal.author?.id else { return }
            NetworkController.main.fetchUser(id: authorId) { (authorInfo) in
                guard let authorInfo = authorInfo else { return }
                self.authorNameLB.text = authorInfo.nickname ?? ""
                if let profileImageURL = authorInfo.profileImageURL{
                    self.authorProfileImageButton.af_setImage(for: .normal, url: profileImageURL)
                }
            }
        }
    }
    private var _postInfo:Post!
}
