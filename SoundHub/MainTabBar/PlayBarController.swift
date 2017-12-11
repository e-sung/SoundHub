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
    
    var currentPostView:DetailViewController?
    var currentPhase:PlayPhase = .Ready
    var playMode:PlayMode = .master
    var masterAudioPlayer:AVPlayer?{
        didSet(oldval){
            playButton?.isEnabled = true
            stopButton?.isEnabled = true
        }
    }
    var mixedAudioPlayers:[AVPlayer]?

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
        if playMode == .mixed {
            guard let mixedAudioPlayers = mixedAudioPlayers else { return }
            for player in mixedAudioPlayers { player.play() }
        }else { masterAudioPlayer?.play() }
    }
    func pauseMusic(){
        playButton?.setBackgroundImage(#imageLiteral(resourceName: "play"), for: .normal)
        currentPhase = .Ready
        if playMode == .mixed{
            guard let mixedAudioPlayers = mixedAudioPlayers else { return }
            for player in mixedAudioPlayers { player.pause() }
        }else{ masterAudioPlayer?.pause() }
    }
    
    @objc func stopMusic(){
        if playMode == .mixed {
            guard let mixedAudioPlayers = mixedAudioPlayers else { return }
            for player in mixedAudioPlayers { player.stop() }
        }else { masterAudioPlayer?.stop() }
        playButton?.setBackgroundImage(#imageLiteral(resourceName: "play"), for: .normal)
    }
    
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
