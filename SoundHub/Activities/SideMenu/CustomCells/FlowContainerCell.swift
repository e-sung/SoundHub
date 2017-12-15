//
//  FlowContainerCell.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 12. 15..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit

class FlowContainerCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PostContainerCellDelegate {
    func shouldGoTo(post: Post) {
        delegate?.shouldGoTo(post: post)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var identifier = ""
        var headerTitle = ""
        var posts:[Post]? = nil
        if indexPath.item == 0 {
            identifier = "postedPostContainer"
            headerTitle = "올린 포스트들"
            posts = userInfo?.post_set
        }else{
            identifier = "likedPostContainer"
            headerTitle = "좋아한 포스트들"
            posts = userInfo?.liked_posts
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! PostContainerCell
        cell.headerTitle = headerTitle
        cell.posts = posts
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.frame.width, height: CGFloat(userInfo!.largerPosts.count)*PostListCell.defaultHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        delegate?.didScrolledTo(page: indexPath.item)
    }
    
    var userInfo:User?{
        didSet(oldVal){
            flowContainer.setHeight(with: CGFloat(userInfo!.largerPosts.count)*PostListCell.defaultHeight)
        }
    }

    @IBOutlet weak var flowContainer: UICollectionView!
    var delegate:FlowContainerCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        flowContainer.delegate = self
        flowContainer.dataSource = self
    }

}

protocol FlowContainerCellDelegate {
    func didScrolledTo(page:Int)->Void
    func shouldGoTo(post:Post)->Void
}
