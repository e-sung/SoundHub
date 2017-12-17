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
        let titleLabel = UILabel(frame: CGRect(x: header.frame.minX + 10, y: header.frame.minY, width: header.frame.width - 10, height: header.frame.height))
        titleLabel.text = title
        titleLabel.font = titleLabel.font.withSize(30)
        header.addSubview(titleLabel)
        return header
    }
    
    func setHeight(with height:CGFloat){
        self.frame = CGRect(x: self.frame.minX, y: self.frame.minY, width: self.frame.width, height: height)
    }
}

extension UIButton{
    func replaceBackGroundImage(from url:URL){
        NetworkController.main.fetchImage(from: url) { (image) in
            DispatchQueue.main.async { self.setBackgroundImage(image, for: .normal) }
        }
    }
    func replaceImage(from url:URL){
        NetworkController.main.fetchImage(from: url) { (image) in
            DispatchQueue.main.async { self.setImage(image, for: .normal) }
        }
    }
}

extension UIImageView{
    func replaceImage(from url:URL){
        NetworkController.main.fetchImage(from: url) { (image) in
            DispatchQueue.main.async { self.image = image }
        }
    }
}
