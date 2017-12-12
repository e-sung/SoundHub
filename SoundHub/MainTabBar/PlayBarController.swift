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
        view.addSubview(playButton)
        
        progressBar = makeProgressBar()
        view.addSubview(progressBar)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(showCurrentMusicContainer))
        view.addGestureRecognizer(tapRecognizer)

        view.isHidden = true
    }

    private var playButton: UIButton!
    private var progressBar: UISlider!
    var mixedAudioPlayers:[AVPlayer]?
    var currentPostView:DetailViewController?
    var mixedAudioContainer:MixedTracksContainerCell?
    
    var currentPhase:PlayPhase = .Ready
    var playMode:PlayMode = .master
    var masterAudioPlayer:AVPlayer?{
        didSet(oldval){
            playButton?.isEnabled = true
            let cmt = CMTime(value: 1, timescale: 10)
            masterAudioPlayer?.addPeriodicTimeObserver(forInterval: cmt, queue: DispatchQueue.main, using: { (cmt) in
                let progress = self.masterAudioPlayer!.currentTime().seconds/self.masterAudioPlayer!.currentItem!.duration.seconds
                self.progressBar.setValue(Float(progress), animated: true)
            })
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
    @objc func progressBarHandler(_ sender:UISlider){
        print(sender.value)
        pauseMusic()
    }
    func playMusic(){
        playButton?.setBackgroundImage(#imageLiteral(resourceName: "pause"), for: .normal)
        currentPhase = .Playing
        if playMode == .mixed {
            mixedAudioContainer?.playMusic()
//            guard let mixedAudioPlayers = mixedAudioPlayers else { return }
//            for player in mixedAudioPlayers { player.play() }
        }else { masterAudioPlayer?.play() }
    }
    func pauseMusic(){
        playButton?.setBackgroundImage(#imageLiteral(resourceName: "play"), for: .normal)
        currentPhase = .Ready
        if playMode == .mixed{
            mixedAudioContainer?.pauseMusic()
//            guard let mixedAudioPlayers = mixedAudioPlayers else { return }
//            for player in mixedAudioPlayers { player.pause() }
        }else{ masterAudioPlayer?.pause() }
    }
    func skimMusic(to point:CGFloat){
        let pointToSeek = CMTimeMake(Int64(point*1000), Int32(1000))
        masterAudioPlayer?.seek(to: pointToSeek)
    }
    
    @objc func stopMusic(){
        if playMode == .mixed {
            mixedAudioContainer?.stopMusic()
//            guard let mixedAudioPlayers = mixedAudioPlayers else { return }
//            for player in mixedAudioPlayers { player.stop() }
        }else { masterAudioPlayer?.stop() }
        playButton?.setBackgroundImage(#imageLiteral(resourceName: "play"), for: .normal)
    }
    
    @objc func showCurrentMusicContainer(){
        let length = masterAudioPlayer!.currentItem!.duration.seconds
        let current = masterAudioPlayer!.currentTime().seconds
        print(current/length)
//        let chartVC = UIStoryboard(name: "GeneralRanking", bundle: nil).instantiateViewController(withIdentifier: "ChartViewController") as! ChartViewController
//        chartVC.show(currentPostView!, sender: nil)
    }
    
    func toggle(to mode:Bool){
        stopMusic()
        if mode == true { playMode = .mixed} else { playMode = .master}
        stopMusic()
    }
}

extension PlayBarController{
    func makeProgressBar()->UISlider{
        let slider = UISlider(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 10))
        slider.addTarget(self, action: #selector(progressBarHandler), for: .valueChanged)
        return slider
    }
    
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
