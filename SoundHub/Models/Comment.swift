//
//  Comment.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 11. 30..
//  Copyright © 2017년 류성두. All rights reserved.
//

import Foundation

struct Comment:Codable{
    let id:Int
    let author:String?
    let post:String?
    let is_mixed:Bool?
    let comment_track:String?
    let instrument:Instrument.RawValue?
    var commentTrackURL:URL?{
        get{
            guard let commentTrack = self.comment_track else { return nil }
            return URL(string: commentTrack.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)!, relativeTo: NetworkController.main.baseAudioURL)!
        }
    }
}
