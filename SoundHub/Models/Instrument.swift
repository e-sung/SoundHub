//
//  Instrument.swift
//  soundHubPractice
//
//  Created by 류성두 on 2017. 11. 27..
//  Copyright © 2017년 류성두. All rights reserved.
//

import Foundation
import UIKit

enum Instrument:String {
    case Vocal = "Vocal"
    case Guitar = "Guitar"
    case Bass = "Bass"
    case Drum = "Drums"
    case Keyboard = "Keyboard"
    case Other = "Other"
    
    static let cases = ["Vocal","Guitar","Bass","Drums","Keyboard", "Other" ]
    var image:UIImage? {
        switch self {
        case .Vocal: return #imageLiteral(resourceName: "vocal")
        case .Guitar: return #imageLiteral(resourceName: "guitar")
        case .Bass: return #imageLiteral(resourceName: "bass")
        case .Drum: return #imageLiteral(resourceName: "drums")
        case .Keyboard: return #imageLiteral(resourceName: "keyboard")
        default: return nil
        }
    }
}
