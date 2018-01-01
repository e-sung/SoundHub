//
//  PlayBarViewController.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 12. 11..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit
import AVFoundation

class PlayBarController:UIViewController{
    
    /// 화면 하단의 플레이바를 담당하는 싱글턴 객체
    static var main:PlayBarController = PlayBarController()
    static func reboot(){ self.main = PlayBarController() }

    private var playButton: UIButton!
    private var progressBar: UISlider!
    private var statusLable: UILabel!
    private var progressBarBeingTouched = false
    /// 비동기 작업이 시작되었을 시점에 뭘 하고 있었는지
    var lastPhase:PlayPhase = .Stopped
    /// 지금 뭘 하고 있는지.
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
    /// 현재 플레이바가 재생하는 대상
    var currentPostView:DetailViewController?{
        willSet(newVal){ if currentPostView !== newVal { currentPhase = .Stopped } }
    }
    /// 플레이바를 보여줄지 말지
    var isHidden:Bool{
        get{ return view.isHidden }
        set(newVal){ view.isHidden = newVal }
    }
    /// 버튼을 누르게 할 수 있게 할지 말지
    var isEnabled:Bool{
        get{ return playButton.isEnabled }
        set(newVal){ DispatchQueue.main.async { self.playButton.isEnabled = newVal } }
    }
    /// 음악 재생률. 0~1 사이
    var progress:Float{
        get{ return progressBar.value }
    }
}

// MARK: Objc Functions
extension PlayBarController{
    @objc private func playButtonHandler(_ sender: UIButton) {
        progressBarBeingTouched = false
        if currentPhase == .Paused || currentPhase == .Stopped { currentPhase = .Playing }
        else if currentPhase == .Playing{ currentPhase = .Paused }
    }
    
    @objc private func progressBarHandler(_ sender:UISlider){
        if progressBarBeingTouched == false { lastPhase = currentPhase }
        progressBarBeingTouched = true
        currentPhase = .Paused
        currentPostView?.seek(to: sender.value)
    }
    
    @objc private func progressBarDragingDidEnded(_ sender:UISlider){
        progressBarBeingTouched = false
        if lastPhase == .Playing { currentPhase = .Playing }
    }

    @objc private func showCurrentMusicContainer(){
        guard let _ = currentPostView else { return }
        delegate?.playBarDidTapped()
    }
}

// MARK: Playable
extension PlayBarController:Playable{

    func play(){ currentPostView?.play() }
    func pause(){ currentPostView?.pause()}
    func stop(){
        currentPostView?.stop()
        reflect(progress: 0)
    }
    func seek(to value:Float){ currentPostView?.seek(to: value) }
    func setVolume(to value: Float) { currentPostView?.setVolume(to: value) }
    func setMute(to value: Bool) { currentPostView?.setMute(to: value) }
    
    func reflect(progress:Float){
        if progressBarBeingTouched == false{
            progressBar.setValue(progress, animated: true)
            currentPostView?.reflect(progress:progress)
        }
    }
    func handleCommentToggle(){
        lastPhase = currentPhase
        pause()
        if lastPhase == .Playing{ play() }
    }
}

// MARK: UI Initialization
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
