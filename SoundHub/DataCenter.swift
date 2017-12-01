//
//  DataCenter.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 12. 1..
//  Copyright © 2017년 류성두. All rights reserved.
//

import Foundation

class DataCenter{
    static let main = DataCenter()
    static let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    var recentPosts:[Post] = []
}
