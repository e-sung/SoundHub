//
//  String.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 12. 6..
//  Copyright © 2017년 류성두. All rights reserved.
//

import Foundation
import AVFoundation

extension String{
    var url:URL{
        get{ return URL(string: self.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)! }
    }
    
    var isValidEmail:Bool {
        get{
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            return emailTest.evaluate(with: self)
        }
    }
    
    var isValidPassword:Bool{
        get{ return self.count > 10 }
    }
    
    static func generateAvMetaData(with value:String, and type:AVMetadataIdentifier)->AVMutableMetadataItem{
        let item = AVMutableMetadataItem()
        item.identifier = type
        item.value = value as (NSCopying & NSObjectProtocol)?
        return item
    }
}

