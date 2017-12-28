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
    private var progressBar: UISlider!
    private var statusLable: UILabel!
    private var progressBarBeingTouched = false
    private var lastPhase:PlayPhase = .Stopped
    var currentPhase:PlayPhase = .Stopped {
        didSet(oldVal){
            switch currentPhase {
            case .Playing:
                statusLable.isHidden = true
                play()
                playButton?.setBackgroundImage(#imageLiteral(resourceName: "pause"), for: .normal)
            case .Stopped:
                statusLable.isHidden = true
                stop()
                playButton?.setBackgroundImage(#imageLiteral(resourceName: "play"), for: .normal)
            case .Paused:
                statusLable.isHidden = true
                pause()
                playButton?.setBackgroundImage(#imageLiteral(resourceName: "play"), for: .normal)
            case .Recording:
                stop()
                playButton.setBackgroundImage(nil, for: .normal)
                statusLable.isHidden = false; statusLable.text = "녹음중"
                play()
            case .PlayingRecord:
                stop()
                statusLable.isHidden = true
                play()
                playButton?.setBackgroundImage(#imageLiteral(resourceName: "pause"), for: .normal)
            }
        }
    }
    enum PlayPhase{
        case Stopped
        case Paused
        case Playing
        case Recording
        case PlayingRecord
    }
    var delegate:PlayBarControllerDelegate?
    var currentPostView:DetailViewController?{
        willSet(newVal){
            if currentPostView !== newVal { currentPhase = .Stopped }
        }
    }
    var isHidden:Bool{
        get{
            return view.isHidden
        }set(newVal){
            view.isHidden = newVal
        }
    }
    var isEnabled:Bool{
        get{
            return playButton.isEnabled
        }set(newVal){
            DispatchQueue.main.async { self.playButton.isEnabled = newVal }
        }
    }
    var progress:Float{
        get{
            return progressBar.value
        }
    }
}

extension PlayBarController{
    @objc func playButtonHandler(_ sender: UIButton) {
        progressBarBeingTouched = false
        if currentPhase == .Paused || currentPhase == .Stopped { currentPhase = .Playing }
        else if currentPhase == .Playing{ currentPhase = .Paused }
    }
    
    @objc func progressBarHandler(_ sender:UISlider){
        if progressBarBeingTouched == false { lastPhase = currentPhase }
        progressBarBeingTouched = true
        currentPhase = .Paused
        currentPostView?.seek(to: sender.value)
    }
    
    @objc func progressBarDragingDidEnded(_ sender:UISlider){
        progressBarBeingTouched = false
        if lastPhase == .Playing { currentPhase = .Playing }
    }

    @objc func showCurrentMusicContainer(){
        delegate?.playBarDidTapped()
    }
}

extension PlayBarController{
    func play(){
        currentPostView?.play()
    }
    func pause(){
        currentPostView?.pause()
    }
    func stop(){
        currentPostView?.stop()
        reflect(progress: 0)
    }
    func seek(to value:Float){
        currentPostView?.seek(to: value)
    }
    func reflect(progress:Float){
        if progressBarBeingTouched == false{
            progressBar.setValue(progress, animated: true)
            currentPostView?.reflect(progress:progress)
        }
    }
    func handleCommentToggle(){
        lastPhase = currentPhase
        pause()
//        seek(to: progress)
        if lastPhase == .Playing{ play() }
    }
}

extension PlayBarController{
    func setUpView(In containerView:UIView){
        setUpMainView(In: containerView)
        setUpPlayButton()
        setUpProgressBar()
        setUpGestureRecognizer()
        setUpStatusLable()
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
    
    private func setUpStatusLable(){
        statusLable = UILabel()
        view.addSubview(statusLable)
        statusLable.textAlignment = .center
        statusLable.textColor = .orange
        let margins = view.layoutMarginsGuide
        statusLable.translatesAutoresizingMaskIntoConstraints = false
        statusLable.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
        statusLable.centerYAnchor.constraint(equalTo: margins.centerYAnchor).isActive = true
        statusLable.heightAnchor.constraint(equalTo: margins.heightAnchor, multiplier: 0.9).isActive = true
        statusLable.widthAnchor.constraint(equalTo: margins.widthAnchor, multiplier: 1.0).isActive = true
        statusLable.isHidden = true
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
}
