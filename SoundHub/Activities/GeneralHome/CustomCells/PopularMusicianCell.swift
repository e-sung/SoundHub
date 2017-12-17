//
//  PopularMusicianCell.swift
//  soundHubPractice
//
//  Created by 류성두 on 25/11/2017.
//  Copyright © 2017 류성두. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class PopularMusicianCell: UICollectionViewCell {
    @IBOutlet weak private var artistImage: UIImageView!
    @IBOutlet weak private var artistNameLabel: UILabel!
    var userInfo:User?{
        didSet(oldVal){
            guard let info = userInfo else { return }
            artistNameLabel.text = info.nickname
            guard let profileImageURL = info.profileImageURL else { return }
            let imageDownloader = UIImageView.af_sharedImageDownloader
            imageDownloader.imageCache?.removeAllImages()
            imageDownloader.sessionManager.session.configuration.urlCache?.removeAllCachedResponses()
            artistImage.af_setImage(withURL: profileImageURL, placeholderImage: #imageLiteral(resourceName: "default-profile"), filter: nil, progress: nil, progressQueue: DispatchQueue.main, imageTransition: .crossDissolve(1), runImageTransitionIfCached: false) { (img) in
            }
        }
    }
}
