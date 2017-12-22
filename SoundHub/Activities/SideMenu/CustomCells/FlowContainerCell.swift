//
//  FlowContainerCell.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 12. 15..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit

class FlowContainerCell: UITableViewCell{
    
    @IBOutlet weak var flowContainer: UICollectionView!
    var delegate:FlowContainerCellDelegate?
    var parent:ProfileViewController!
    var userInfo:User?
    override func awakeFromNib() {
        super.awakeFromNib()
        flowContainer.delegate = self
        flowContainer.dataSource = self
    }
}

extension FlowContainerCell:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    var isScrollEnabled:Bool{
        get{
            return (flowContainer.allCells[0] as! PostContainerCell).isScrollEnabled
        }set(newVal){
            for cell in flowContainer.allCells{
                let cell = cell as! PostContainerCell
                cell.postTB.isScrollEnabled = newVal
            }
        }
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
            headerTitle = "작성한 포스트"
            posts = userInfo?.postedPost
        }else{
            identifier = "likedPostContainer"
            headerTitle = "좋아한 포스트"
            posts = userInfo?.liked_posts 
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! PostContainerCell
        cell.posts = posts
        cell.headerTitle = headerTitle
        cell.delegate = self
        cell.parent = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.frame.width, height: self.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as? PostContainerCell
        cell?.scrollToTopWith(animation: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as? PostContainerCell
        cell?.scrollToTopWith(animation: false)
    }
}

extension FlowContainerCell:PostContainerCellDelegate{
    func shouldGoTo(post: Post) {
        delegate?.shouldGoTo(post: post)
    }
}

protocol FlowContainerCellDelegate {
    func shouldGoTo(post:Post)->Void
}
