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
        return URL(string: self.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)!
    }
    
    var isValidEmail:Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    var isValidPassword:Bool {
        return self.count > 10
    }
    
    static func generateAvMetaData(with value:String, and type:AVMetadataIdentifier) -> AVMutableMetadataItem{
        let item = AVMutableMetadataItem()
        item.identifier = type
        item.value = value as (NSCopying & NSObjectProtocol)?
        return item
    }
    
    /**
     예) "AudioUnit"->"Audio\nUnit"
     */
    var brokenAtCaptial:String{
        let startingIndex = self.startIndex
        var result = String(self[self.startIndex])
        var lastString = String(self[self.startIndex])
        for i in 1..<self.count{
            let index = self.index(startingIndex, offsetBy: String.IndexDistance(i))
            let ch = String(self[index])
            
            if ch.lowercased() != ch
                && lastString.lowercased() == lastString
                && !(lastString == "i" && ch == "P")
            {
                result.append("\n")
            }
            result.append(ch)
            lastString = ch
        }
        return result
    }
}
