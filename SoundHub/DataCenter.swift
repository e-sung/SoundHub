//
//  DataCenter.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 12. 1..
//  Copyright © 2017년 류성두. All rights reserved.
//

import Foundation
import UIKit

class DataCenter{
    static var main = DataCenter()
    static let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    var recentPosts:[Post] = []
    
    var homePages:[Categori:HomePage] = [
        .general:HomePage(pop_users: [], pop_posts: [], recent_posts: []),
        .genre:HomePage(pop_users: [], pop_posts: [], recent_posts: []),
        .instrument:HomePage(pop_users: [], pop_posts: [], recent_posts: [])
    ]
    
    var userProfileImage:UIImage?
    var userHeaderImage:UIImage?
    var userId:Int{
        get{
            if _userId == nil {
                _userId = UserDefaults.standard.integer(forKey: id)
            }
            return _userId!
        }
    }
    private var _userId:Int?
    var userNickName:String{
        get{
            if _userNickName == nil{
                _userNickName = UserDefaults.standard.string(forKey: nickname)
            }
            return _userNickName!
        }
    }
    private var _userNickName:String?
    
    func removeUserProfileImageCache(){
        let imageDownloader = UIImageView.af_sharedImageDownloader
        let buttonDownloader = UIButton.af_sharedImageDownloader
        imageDownloader.imageCache?.removeAllImages()
        buttonDownloader.imageCache?.removeAllImages()
        imageDownloader.sessionManager.session.configuration.urlCache?.removeAllCachedResponses()
    }
}
struct HomePage:Codable{
    var pop_users:[User]
    var pop_posts:[Post]
    var recent_posts:[Post]
}

enum Categori:String{
    case general = " "
    case genre = "genre"
    case instrument = "instrument"
}
