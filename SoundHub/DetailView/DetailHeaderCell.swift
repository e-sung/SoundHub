//
//  DetailHeaderCell.swift
//  soundHubPractice
//
//  Created by 류성두 on 2017. 11. 26..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit

class DetailHeaderCell: UITableViewCell {

    @IBOutlet weak var authorProfileImage: UIImageView!
    
    @IBOutlet weak var postTitleLB: UILabel!
    
    @IBOutlet weak var authorNameLB: UILabel!
    
    @IBOutlet weak var numberOfLikesLB: UILabel!
    
    @IBOutlet weak var numberOfPlaysLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
