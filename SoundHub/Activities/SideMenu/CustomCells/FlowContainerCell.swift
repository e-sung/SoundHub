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
    var userInfo:User?{
        didSet(oldVal){
            guard let userInfo = userInfo else { return }
            flowContainer.setHeight(with: CGFloat(userInfo.largerPosts.count)*PostListCell.defaultHeight)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        flowContainer.delegate = self
        flowContainer.dataSource = self
    }
}

extension FlowContainerCell:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
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
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.frame.width, height: CGFloat(userInfo!.largerPosts.count)*PostListCell.defaultHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        delegate?.didScrolledTo(page: indexPath.item)
    }
}

extension FlowContainerCell:PostContainerCellDelegate{
    func shouldGoTo(post: Post) {
        delegate?.shouldGoTo(post: post)
    }
}

protocol FlowContainerCellDelegate {
    func didScrolledTo(page:Int)->Void
    func shouldGoTo(post:Post)->Void
}
