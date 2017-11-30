//
//  URLContainer.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 11. 30..
//  Copyright © 2017년 류성두. All rights reserved.
//

import Foundation

class URLContainer{
    var delegate:URLContainerDelegate?
    var list:[URL] = []{
        didSet(oldVal){
            delegate?.listCountDidSet(to: list.count, In: self)
        }
    }
}

protocol URLContainerDelegate {
    func listCountDidSet(to value:Int, In container:URLContainer)
}
