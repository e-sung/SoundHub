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
    let title:String?
    let author:String?
    let instrument:String?
    let genre:String?
    let liked:[Int]?
    let num_liked:Int?
    let num_comments:Int?
    let created_date:String?
    let master_track:String?
    let author_track:String?
    let mixed_tracks:[String:[Comment]]?
    let comment_tracks:[String:[Comment]]?
    var authorTrackRemoteURL:URL?{
        get{
            guard let authorTrack = self.author_track else { return nil }
            return URL(string: authorTrack.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)!, relativeTo: NetworkController.main.baseMediaURL)!
        }
    }
    var masterTrackRemoteURL:URL?{
        get{
            guard let masterTrack = self.master_track else { return nil }
            return URL(string: masterTrack.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)!, relativeTo: NetworkController.main.baseMediaURL)!
        }
    }
}

