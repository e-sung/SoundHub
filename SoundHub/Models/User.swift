//
//  User.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 11. 29..
//  Copyright © 2017년 류성두. All rights reserved.
//

import Foundation

struct User:Codable{
    let id:Int
    let email:String
    let nickname:String
    let instrument:String
    let is_staff:Bool
    let is_active:Bool
    let last_login:String?
}
