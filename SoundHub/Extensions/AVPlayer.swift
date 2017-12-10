//
//  AVPlayer.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 12. 10..
//  Copyright © 2017년 류성두. All rights reserved.
//

import Foundation
import AVFoundation

extension AVPlayer{
    func stop(){
        self.pause()
        self.seek(to: CMTimeMake(0, 1))
    }
}
