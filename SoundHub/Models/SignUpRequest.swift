//
//  SignUpRequest.swift
//  soundHubPractice
//
//  Created by 류성두 on 2017. 11. 27..
//  Copyright © 2017년 류성두. All rights reserved.
//

import Foundation

struct signUpRequest:Codable{
    var email:String
    var nickname:String
    var instrument:Instrument.RawValue
    var password1:String
    var password2:String
}
