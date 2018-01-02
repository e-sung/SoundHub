//
//  LoginResponse.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 11. 30..
//  Copyright © 2017년 류성두. All rights reserved.
//

import Foundation

struct LoginResponse: Codable {
    let token: String?
    let user: User?
}
