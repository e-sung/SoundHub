//
//  User.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 11. 29..
//  Copyright © 2017년 류성두. All rights reserved.
//

import Foundation

struct User:Codable{
    let id:Int
    let email:String
    let nickname:String
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
    var largerPosts:[Post]{
        get{
            if let postedPosts = self.post_set{
                if let likedPosts = self.liked_posts{
                    if postedPosts.count > likedPosts.count { return postedPosts }
                    else { return likedPosts }
                }else{ return postedPosts }
                
            }else if let likedPosts = self.liked_posts{ return likedPosts }
            else{ return [] }
        }
    }
}

