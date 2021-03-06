//
//  UIView.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 12. 7..
//  Copyright © 2017년 류성두. All rights reserved.
//

import Foundation
import UIKit
extension UIView {
    /**
     테이블뷰 등의 헤더에 쓰일 뷰를 생성하는 함수. width는 메인스크린과 같은 크기이며, height의 기본값은 100이다.
    */
    static func generateHeaderView(with title: String, and height: Int = 100) -> UIView {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: height))
        header.backgroundColor = .white
        let titleLabel = UILabel(frame: CGRect(x: header.frame.minX + 10, y: header.frame.minY,
                                               width: header.frame.width - 10, height: header.frame.height))
        titleLabel.text = title
        titleLabel.font = titleLabel.font.withSize(30)
        header.addSubview(titleLabel)
        return header
    }

    func setHeight(with height: CGFloat) {
        self.frame = CGRect(x: self.frame.minX, y: self.frame.minY, width: self.frame.width, height: height)
    }
}
