//
//  FlowContainerCell.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 12. 15..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit

class FlowContainerCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var identifier = ""
        var posts:[Post]? = nil
        if indexPath.item == 0 {
            identifier = "postedPostContainer"
            posts = userInfo?.post_set
        }else{
            identifier = "likedPostContainer"
            posts = userInfo?.liked_posts
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! PostContainerCell
        cell.posts = posts
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.frame.width, height: CGFloat(userInfo!.largerPosts.count)*PostListCell.defaultHeight)
    }
    
    var userInfo:User?{
        didSet(oldVal){
            flowContainer.setHeight(with: CGFloat(userInfo!.largerPosts.count)*PostListCell.defaultHeight)
        }
    }

    @IBOutlet weak var flowContainer: UICollectionView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        flowContainer.delegate = self
        flowContainer.dataSource = self
    }

}
