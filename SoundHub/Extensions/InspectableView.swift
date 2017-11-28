//
//  Button.swift
//  LoginPractice
//
//  Created by 류성두 on 2017. 11. 24..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit

@IBDesignable
extension UIView {
    @IBInspectable public var borderColor:UIColor? {
        get{
            return layer.borderColor == nil ? UIColor.white : UIColor(cgColor: layer.borderColor!)
        }
        set(newColor){
            layer.borderColor = newColor?.cgColor
        }
    }
    @IBInspectable public var borderWidth:CGFloat {
        get{
            return layer.borderWidth
        }
        set(newWidth){
            layer.borderWidth = newWidth
        }
    }
    @IBInspectable public var cornerRadius:CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}
