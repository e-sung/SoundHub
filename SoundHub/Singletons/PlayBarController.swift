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
    var phaseBeforeProgressBarDrag:DetailViewController.PlayPhase = .Ready
    var delegate:PlayBarControllerDelegate?
    var currentPostView:DetailViewController?{
        willSet(newVal){
            if currentPostView !== newVal {
                stopMusic()
            }
        }
    }
    var isHidden:Bool{
        get{
            return view.isHidden
        }set(newVal){
            view.isHidden = newVal
            delegate?.didAppeared()
        }
    }
    var masterAudioPlayer:AVPlayer?
}

extension PlayBarController{
    @objc func playButtonHandler(_ sender: UIButton) {
        progressBarBeingTouched = false
        if currentPostView?.currentPhase == .Ready {
            playMusic()
        }else if currentPostView?.currentPhase == .Playing{
            pauseMusic()
        }
    }
    @objc func progressBarDragingDidEnded(_ sender:UISlider){
        progressBarBeingTouched = false
        if phaseBeforeProgressBarDrag == .Playing {
            playMusic()
        }
    }
    @objc func progressBarHandler(_ sender:UISlider){
        if progressBarBeingTouched == false {
            phaseBeforeProgressBarDrag = (currentPostView?.currentPhase)!
        }
        progressBarBeingTouched = true
        pauseMusic()
        currentPostView?.seek(to: sender.value)
    }
    
    @objc func stopMusic(){
        currentPostView?.stop()
        playButton?.setBackgroundImage(#imageLiteral(resourceName: "play"), for: .normal)
        reflect(progress: 0)
    }
    
    @objc func showCurrentMusicContainer(){
        delegate?.playBarDidTapped()
    }
}

extension PlayBarController{
    func playMusic(){
        playButton?.setBackgroundImage(#imageLiteral(resourceName: "pause"), for: .normal)
        currentPostView?.play()
    }
    func pauseMusic(){
        playButton?.setBackgroundImage(#imageLiteral(resourceName: "play"), for: .normal)
        currentPostView?.pause()
    }
    func reflect(progress:Float){
        if progressBarBeingTouched == false{
            progressBar.setValue(progress, animated: true)
            currentPostView?.reflect(progress:progress)
        }
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
        playButton.setBackgroundImage(#imageLiteral(resourceName: "play"), for: .normal)
        playButton.addTarget(self, action: #selector(playButtonHandler), for: .touchUpInside)
    }
    
    private func setUpProgressBar(){
        progressBar = UISlider()
        view.addSubview(progressBar)
        setAutoLayoutOfProgressBar()
        progressBar.addTarget(self, action: #selector(progressBarHandler), for: .valueChanged)
        progressBar.addTarget(self, action: #selector(progressBarDragingDidEnded), for: .touchUpInside)
        progressBar.addTarget(self, action: #selector(progressBarDragingDidEnded), for: .touchUpOutside)
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

protocol PlayBarControllerDelegate{
    func playBarDidTapped()->Void
    func didAppeared()->Void
}
