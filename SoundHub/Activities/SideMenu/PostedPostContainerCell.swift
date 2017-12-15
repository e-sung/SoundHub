//
//  PostedPostContainerCell.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 12. 15..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit

class PostedPostContainerCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {
    
    var posts:[Post]?{
        didSet(oldVal){
            postTB.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let posts = posts else { return 0 }
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postedPostCell", for: indexPath) as! PostListCell
        guard let posts = posts else { return cell }
        cell.postInfo = posts[indexPath.item]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return PostListCell.defaultHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    
    
    @IBOutlet weak var postTB: UITableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        postTB.delegate = self
        postTB.dataSource = self
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
