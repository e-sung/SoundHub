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
    
    let view = UIView()
    var delegate:MainTabBarController!
    func setUpView(){
        view.frame = delegate.tabBar.frame
        view.backgroundColor = .black
        
        playButton = makePlayButton()
        view.addSubview(playButton!)

        view.isHidden = true
    }

    private var playButton: UIButton!
    var mixedAudioPlayers:[AVPlayer]?
    var currentPostView:DetailViewController?
    var currentPhase:PlayPhase = .Ready
    var playMode:PlayMode = .master
    var masterAudioPlayer:AVPlayer?{
        didSet(oldval){
            playButton?.isEnabled = true
        }
    }
}

extension PlayBarController{
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
    func makePlayButton()->UIButton{
        let buttonWidth = delegate.tabBar.frame.height * 0.8
        let buttonSize = CGSize(width: buttonWidth, height: buttonWidth)
        let playButton = UIButton()
        let playButtonOrigin = CGPoint(x: delegate.tabBar.frame.width/2 - buttonWidth/2, y: delegate.tabBar.frame.height*0.2)
        playButton.frame = CGRect(origin: playButtonOrigin, size: buttonSize)
        playButton.setBackgroundImage(#imageLiteral(resourceName: "play"), for: .normal)
        playButton.isEnabled = false
        playButton.addTarget(self, action: #selector(playButtonHandler), for: .touchUpInside)
        return playButton
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
