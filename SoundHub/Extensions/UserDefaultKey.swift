//
//  UserDefaultKey.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 12. 6..
//  Copyright © 2017년 류성두. All rights reserved.
//

import Foundation

/// UserDefault Key For Token
let keyForToken = "token"
/// UserDefault Key For nickname
let keyForNickName = "nickname"
/// UserDefault Key for user's main Instrumet
let keyForInstruments = "instrument"
/// UserDefault Key for user's ID
let keyForUserId = "id"

extension UserDefaults{
    func save(_ socialLoginResult:NSDictionary){
        guard let newToken = socialLoginResult["token"] as? String else { return }
        guard let userInfo = socialLoginResult["user"] as? NSDictionary else { return }
        guard let userId = userInfo["id"] as? Int else { return }
        guard let nickName = userInfo["nickname"] as? String else { return }
        guard let instrument = userInfo["instrument"] as? String else { return }
        self.set(newToken, forKey: keyForToken)
        self.set(nickName, forKey: keyForNickName)
        self.set(userId, forKey: keyForUserId)
        self.set(instrument, forKey: keyForInstruments)
    }
    


}
