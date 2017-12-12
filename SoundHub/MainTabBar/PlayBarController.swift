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
    
    static let main:PlayBarController = PlayBarController()
    let view = UIView()

    private var playButton: UIButton!
    var progressBar: UISlider!
    var progressBarBeingTouched = false
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
                if self.progressBarBeingTouched == false {
                    self.progressBar.setValue(Float(progress), animated: true)
                }
            })
        }
    }
}

extension PlayBarController{
    @objc func playButtonHandler(_ sender: UIButton) {
        progressBarBeingTouched = false
        if currentPhase == .Ready {
            playMusic()
        }else if currentPhase == .Playing{
            pauseMusic()
        }
    }
    @objc func progressBarHandler(_ sender:UISlider){
        progressBarBeingTouched = true
        pauseMusic()
        if playMode == .mixed {
            mixedAudioContainer?.seek(to: sender.value)
        }else{
            masterAudioPlayer?.seek(to: sender.value)
        }
    }
//    @objc func progressBarTouchDown(_ sender:UISlider){
//        pauseMusic()
//        progressBarBeingTouched = true
//    }
//    @objc func progressBarTouchUp(_ sender:UISlider){
//        progressBarBeingTouched = false
//        playMusic()
//    }
    
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
}

extension PlayBarController{
    func playMusic(){
        playButton?.setBackgroundImage(#imageLiteral(resourceName: "pause"), for: .normal)
        currentPhase = .Playing
        if playMode == .mixed {
            mixedAudioContainer?.playMusic()
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
    func toggle(to mode:Bool){
        stopMusic()
        if mode == true { playMode = .mixed} else { playMode = .master}
        stopMusic()
    }
}

extension PlayBarController{
    func setUpView(In containerView:UIView){
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        view.heightAnchor.constraint(equalToConstant: 60).isActive = true
        view.backgroundColor = .black
        
        playButton = UIButton()
        view.addSubview(playButton)
        playButton = setAutoLayout(of:playButton)

        progressBar = UISlider()
        view.addSubview(progressBar)
        progressBar = setAutoLayout(of: progressBar)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(showCurrentMusicContainer))
        view.addGestureRecognizer(tapRecognizer)
        
        view.isHidden = true
    }
    
    private func setAutoLayout(of slider:UISlider)->UISlider{
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        slider.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        slider.centerYAnchor.constraint(equalTo: view.topAnchor).isActive = true
        slider.addTarget(self, action: #selector(progressBarHandler), for: .valueChanged)
        return slider
    }
    
    private func setFrame(of slider:UISlider)->UISlider{
        slider.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 10)
        slider.addTarget(self, action: #selector(progressBarHandler), for: .valueChanged)
        return slider
    }
    
    private func setFrame(of button:UIButton)->UIButton{
        let buttonWidth = self.view.frame.height * 0.8
        button.frame = CGRect(x: view.frame.width/2 - buttonWidth/2, y:self.view.frame.height*0.2 , width: buttonWidth, height: buttonWidth)
        button.setBackgroundImage(#imageLiteral(resourceName: "play"), for: .normal)
        button.isEnabled = false
        button.addTarget(self, action: #selector(playButtonHandler), for: .touchUpInside)
        return playButton
    }
    
    private func setAutoLayout(of button:UIButton)->UIButton{
        let margins = view.layoutMarginsGuide
        button.translatesAutoresizingMaskIntoConstraints = false
        button.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: margins.centerYAnchor).isActive = true
        button.heightAnchor.constraint(equalTo: margins.heightAnchor, multiplier: 0.9).isActive = true
        button.widthAnchor.constraint(equalTo: playButton.heightAnchor, multiplier: 1.0).isActive = true
        button.setBackgroundImage(#imageLiteral(resourceName: "play"), for: .normal)
        button.isEnabled = false
        button.addTarget(self, action: #selector(playButtonHandler), for: .touchUpInside)
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
