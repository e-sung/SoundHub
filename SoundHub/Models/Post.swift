//
//  Post.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 11. 29..
//  Copyright © 2017년 류성두. All rights reserved.
//

import Foundation

/// [Post 객체 API](https://nachwon.gitbooks.io/soundhub/content/post/post-detail.html) 참조
struct Post: Codable {
    let id: Int?
    let title: String?
    var author: User?
    let instrument: String?
    let genre: String?
    let bpm: Int?
    let post_img: String?
    let liked: [Int]?
    let num_liked: Int?
    let num_comments: Int?
    let created_date: String?
    let master_track: String?
    let author_track: String?
    let mixed_tracks: [String: [Comment]]?
    let comment_tracks: [String: [Comment]]?
    var authorTrackRemoteURL: URL? {
        guard let authorTrack = self.author_track else { return nil }
        return URL(string: authorTrack.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)!,
                   relativeTo: NetworkController.main.baseMediaURL)!
    }
    /// 만약 nil 이면, authorTrackRemoteURL을 반환함
    var masterTrackRemoteURL: URL? {
        guard let masterTrack = self.master_track else { return authorTrackRemoteURL }
        return URL(string: masterTrack.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)!,
                   relativeTo: NetworkController.main.baseMediaURL)!
    }
    var albumCoverImageURL: URL? {
        guard let postImageURL = self.post_img else { return nil }
        return URL(string: postImageURL, relativeTo: NetworkController.main.baseMediaURL)
    }

    var numOfMixedTracks: Int {
        guard let mixed_tracks = mixed_tracks else { return 0 }
        var accum = 0
        for i in 0..<Instrument.cases.count {
            let inst = Instrument.cases[i]
            if mixed_tracks.keys.contains(inst) {
                for _ in 0..<mixed_tracks[inst]!.count {
                    accum += 1
                }
            }
        }
        return accum
    }
    var numOfCommentTracks: Int {
        guard let comment_tracks = comment_tracks else { return 0 }
        var accum = 0
        for i in 0..<Instrument.cases.count {
            let inst = Instrument.cases[i]
            if comment_tracks.keys.contains(inst) {
                for _ in 0..<comment_tracks[inst]!.count {
                    accum += 1
                }
            }
        }
        return accum
    }
}
