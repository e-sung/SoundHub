//
//  String.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 12. 6..
//  Copyright © 2017년 류성두. All rights reserved.
//

import Foundation

extension String{
    var url:URL{
        get{
            return URL(string: self.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)!
        }
    }
}
