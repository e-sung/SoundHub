//
//  UIView.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 12. 7..
//  Copyright © 2017년 류성두. All rights reserved.
//

import Foundation
import UIKit
extension UIView{
    static func generateHeaderView(with title:String, and height:Int = 100)->UIView{
        let header = UIView(frame: CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: height))
        header.backgroundColor = .white
        let titleLabel = UILabel(frame: header.frame)
        titleLabel.text = title
        titleLabel.font = titleLabel.font.withSize(30)
        header.addSubview(titleLabel)
        return header
    }
}