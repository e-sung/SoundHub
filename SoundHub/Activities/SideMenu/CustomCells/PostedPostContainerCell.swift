//
//  PostedPostContainerCell.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 12. 15..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit

class PostContainerCell: UICollectionViewCell{
    var posts:[Post]?
    var delegate:PostContainerCellDelegate?
    var firstCell:PostListCell!
    var lastOffset:CGFloat = 0
    var parent:FlowContainerCell!
    var headerTitle:String!
    static var headerHeight:CGFloat = 50
    var isScrolling = false
    @IBOutlet weak var postTB: UITableView!
    
    override func awakeFromNib() {
        postTB.delegate = self
        postTB.dataSource = self
    }
}

extension PostContainerCell: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let posts = posts else { return 1 }
        if posts.count == 0 { return 1 }
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postedPostCell", for: indexPath) as! PostListCell
        guard let posts = posts else { return cell }
        if posts.count > 0 {
            cell.postInfo = posts[indexPath.item]
        }
        if indexPath == IndexPath(item: 0, section: 0){
            firstCell = cell
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return PostListCell.defaultHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let posts = posts else { return }
        if posts.count == 0 { return }
        delegate?.shouldGoTo(post: posts[indexPath.item])
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView.generateHeaderView(with: headerTitle, and: Int(PostContainerCell.headerHeight))
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return PostContainerCell.headerHeight
    }
        
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        isScrolling = true
        if lastOffset > scrollView.contentOffset.y {
            if postTB.visibleCells.contains(firstCell){
                postTB.isScrollEnabled = false
                parent.parent.mainTV.scrollToRow(at: IndexPath(item:0,section:0), at: .top, animated: true)
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView) {
        isScrolling = false
    }

}

extension PostContainerCell{
    var isScrollEnabled:Bool{
        get{
            return postTB.isScrollEnabled
        }set(newVal){
            return postTB.isScrollEnabled = newVal
        }
    }
    func scrollToTopWith(animation:Bool){
        postTB.scrollToRow(at: IndexPath(item:0,section:0), at: .top, animated: animation)
    }
}

protocol PostContainerCellDelegate {
    func shouldGoTo(post:Post) -> Void
    var isScrollEnabled:Bool{ get set }
}
