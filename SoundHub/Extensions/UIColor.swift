//
//  UIColor.swift
//  SoundHub
//
//  Created by esung on 2017. 12. 26..
//  Copyright © 2017년 류성두. All rights reserved.
//

import Foundation

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(red:   .random(),
                       green: .random(),
                       blue:  .random(),
                       alpha: 1.0)
    }
}
