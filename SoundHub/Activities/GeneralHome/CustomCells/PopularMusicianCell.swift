//
//  PopularMusicianCell.swift
//  soundHubPractice
//
//  Created by 류성두 on 25/11/2017.
//  Copyright © 2017 류성두. All rights reserved.
//

import UIKit

class PopularMusicianCell: UICollectionViewCell {
    @IBOutlet weak private var artistImage: UIImageView!
    @IBOutlet weak private var artistNameLabel: UILabel!
    var userInfo:User?{
        didSet(oldVal){
            guard let info = userInfo else { return }
            artistNameLabel.text = info.nickname
            artistImage.replaceImage(from: info.profileImageURL)
        }
    }
}
