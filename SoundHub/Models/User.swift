//
//  User.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 11. 29..
//  Copyright © 2017년 류성두. All rights reserved.
//

import Foundation

/// [User 객체 API](https://nachwon.gitbooks.io/soundhub/content/user/user-retrieve.html) 참고
struct User:Codable{
    let id:Int?
    let email:String?
    let nickname:String?
    let profile_img:String?
    let profile_bg:String?
    let genre:String?
    let instrument:String?
    let total_liked:Int?
    let is_staff:Bool?
    let is_active:Bool?
    let last_login:String?
    let post_set:[Post]?
    let liked_posts:[Post]?
    let num_followings:Int?
    let num_followers:Int?
    var profileImageURL:URL?{
        get{
            guard let profileImgAddr = profile_img else { return nil }
            return URL(string: "\(profileImgAddr)", relativeTo: NetworkController.main.baseMediaURL)!
        }
    }
    var headerImageURL:URL?{
        get{
            guard let headerImgAddr = profile_bg else { return nil }
            return URL(string: "\(headerImgAddr)", relativeTo: NetworkController.main.baseMediaURL)!
        }
    }
    static var isLoggedIn:Bool{
        get{
            if let _ = UserDefaults.standard.string(forKey: "id"){ return true }
            return false
        }
    }
}

