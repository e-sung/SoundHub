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
    var delegate:PlayBarControllerDelegate?
    var currentPostView:DetailViewController?
    var mixedAudioContainer:MixedTracksContainerCell?
    
    var currentPhase:PlayPhase = .Ready
    var playMode:PlayMode = .master
    var masterAudioPlayer:AVPlayer?{
        didSet(oldval){
            playButton!.isEnabled = true
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
        }else { masterAudioPlayer?.stop() }
        playButton?.setBackgroundImage(#imageLiteral(resourceName: "play"), for: .normal)
    }
    
    @objc func showCurrentMusicContainer(){
        delegate?.playBarDidTapped()
    }
}

extension PlayBarController{
    func playMusic(){
        playButton?.setBackgroundImage(#imageLiteral(resourceName: "pause"), for: .normal)
        currentPhase = .Playing
        if playMode == .mixed { mixedAudioContainer?.playMusic() }
        else { masterAudioPlayer?.play() }
    }
    func pauseMusic(){
        playButton?.setBackgroundImage(#imageLiteral(resourceName: "play"), for: .normal)
        currentPhase = .Ready
        if playMode == .mixed{ mixedAudioContainer?.pauseMusic() }
        else{ masterAudioPlayer?.pause() }
    }
    func toggle(to mode:Bool){
        stopMusic()
        if mode == true { playMode = .mixed} else { playMode = .master}
        stopMusic()
    }
}

extension PlayBarController{
    func setUpView(In containerView:UIView){
        setUpMainView(In: containerView)
        setUpPlayButton()
        setUpProgressBar()
        setUpGestureRecognizer()
    }
    
    private func setUpMainView(In containerView:UIView){
        setUpAutoLayoutOfView(In: containerView)
        view.backgroundColor = .black
        view.isHidden = true
    }
    
    private func setUpPlayButton(){
        playButton = UIButton()
        view.addSubview(playButton)
        setAutoLayoutOfPlayButton()
        playButton.isEnabled = false
        playButton.setBackgroundImage(#imageLiteral(resourceName: "play"), for: .normal)
        playButton.addTarget(self, action: #selector(playButtonHandler), for: .touchUpInside)
    }
    
    private func setUpProgressBar(){
        progressBar = UISlider()
        view.addSubview(progressBar)
        setAutoLayoutOfProgressBar()
        progressBar.addTarget(self, action: #selector(progressBarHandler), for: .valueChanged)
    }
    
    private func setUpGestureRecognizer(){
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(showCurrentMusicContainer))
        view.addGestureRecognizer(tapRecognizer)
    }
    
    private func setUpAutoLayoutOfView(In containerView:UIView){
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        view.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }

    private func setAutoLayoutOfPlayButton(){
        let margins = view.layoutMarginsGuide
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: margins.centerYAnchor).isActive = true
        playButton.heightAnchor.constraint(equalTo: margins.heightAnchor, multiplier: 0.9).isActive = true
        playButton.widthAnchor.constraint(equalTo: playButton.heightAnchor, multiplier: 1.0).isActive = true
    }

    private func setAutoLayoutOfProgressBar(){
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        progressBar.centerYAnchor.constraint(equalTo: view.topAnchor).isActive = true
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

protocol PlayBarControllerDelegate{
    func playBarDidTapped()->Void
}
