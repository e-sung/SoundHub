//
//  AVPlayer.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 12. 10..
//  Copyright © 2017년 류성두. All rights reserved.
//

import Foundation
import AVFoundation

var AVPlayerTimeObserver:Any?

extension AVPlayer{
    
    func stop(){
        self.pause()
        self.seek(to: CMTimeMake(0, 1))
    }
    
    func seek(to proportion:Float){
        let scale:Float = 1000
        let duration = Float(self.currentItem!.duration.seconds)
        if duration.isNaN { return }
        let point = CMTimeMake(Int64(proportion*duration*scale), Int32(scale))
        self.seek(to: point)
    }
    
    var isPlaying: Bool {
        if (self.rate != 0 && self.error == nil) {
            return true
        } else {
            return false
        }
    }
}
