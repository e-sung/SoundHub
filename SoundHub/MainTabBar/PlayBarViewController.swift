//
//  PlayBarViewController.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 12. 11..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit
import AVFoundation

class PlayBarController{
    
    var currentPhase:PlayPhase = .Ready
    var playMode:PlayMode = .master
    var masterAudioPlayer:AVPlayer?{
        didSet(oldval){
            playButton?.isEnabled = true
            stopButton?.isEnabled = true
        }
    }
    var mixedTrackContainer:MixedTracksContainerCell?

    var playButton: UIButton?{
        didSet(oldval){
            playButton?.addTarget(self, action: #selector(playButtonHandler), for: .touchUpInside)
        }
    }
    var stopButton: UIButton?{
        didSet(oldVal){
            stopButton?.addTarget(self, action: #selector(stopMusic), for: .touchUpInside)
        }
    }
    
    @objc func playButtonHandler(_ sender: UIButton) {
        if currentPhase == .Ready {
            playMusic()
        }else if currentPhase == .Playing{
            pauseMusic()
        }
    }
    func playMusic(){
        playButton?.setBackgroundImage(#imageLiteral(resourceName: "pause"), for: .normal)
        currentPhase = .Playing
        if playMode == .mixed { mixedTrackContainer?.playMusic() }
        else { masterAudioPlayer?.play() }
    }
    func pauseMusic(){
        playButton?.setBackgroundImage(#imageLiteral(resourceName: "play"), for: .normal)
        currentPhase = .Ready
        if playMode == .mixed{ mixedTrackContainer?.pauseMusic() }
        else{ masterAudioPlayer?.pause() }
    }
    
    @objc func stopMusic(){
        if playMode == .mixed { mixedTrackContainer?.stopMusic() }
        else { masterAudioPlayer?.stop() }
        playButton?.setBackgroundImage(#imageLiteral(resourceName: "play"), for: .normal)
    
    func toggle(to mode:Bool){
        stopMusic()
        if mode == true { playMode = .mixed} else { playMode = .master}
        stopMusic()
    }
}


extension PlayBarController{
    enum PlayPhase{
        case Ready
        case Playing
        case Recording
    }
    enum PlayMode{
        case master
        case mixed
    }
}
