//
//  Post.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 11. 29..
//  Copyright © 2017년 류성두. All rights reserved.
//

import Foundation

struct Post:Codable{
    let id:Int
    let title:String
    let author:User
    let instrument:String
    let genre:String
    let liked:[Int]?
    let num_liked:Int
    let num_comments:Int
    let created_date:String
    let master_track:String?
    let author_track:String?
    let comment_tracks:[String:[Comment]]?
}

