//
//  Generics.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 12. 8..
//  Copyright © 2017년 류성두. All rights reserved.
//

import Foundation

func initializeDic<T>(of type: T.Type,with keys:[String])->[String:[T]]{
    var dic = [String:[T]]()
    for key in keys { dic[key] = [] }
    return dic
}
