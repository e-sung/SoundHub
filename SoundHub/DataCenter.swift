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
    static let main = DataCenter()
    static let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    var recentPosts:[Post] = []
    
    var homePages:[category:HomePage] = [
        .general:HomePage(pop_users: [], pop_posts: [], recent_posts: []),
        .genre:HomePage(pop_users: [], pop_posts: [], recent_posts: []),
        .instrument:HomePage(pop_users: [], pop_posts: [], recent_posts: [])
    ]
    
    var userProfileImage:UIImage?
    var userHeaderImage:UIImage?
}
struct HomePage:Codable{
    var pop_users:[User]
    var pop_posts:[Post]
    var recent_posts:[Post]
}

enum category{
    case general
    case genre
    case instrument
}
