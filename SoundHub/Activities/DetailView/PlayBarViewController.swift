//
//  PlayBarViewController.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 12. 11..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit
import AVFoundation

class PlayBarViewController: UIViewController {
    
    private var currentPhase:Phase = .Ready
    private var playMode:PlayMode = .master
    var masterAudioPlayer:AVPlayer?
    var mixedTrackContainer:MixedTracksContainerCell?

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBAction func playButtonHandler(_ sender: UIButton) {
        if currentPhase == .Ready {
            playMusic()
        }else if currentPhase == .Playing{
            pauseMusic()
        }
    }
    func playMusic(){
        
        playButton.setImage( #imageLiteral(resourceName: "pause"), for: .normal)
        currentPhase = .Playing
        if playMode == .mixed { mixedTrackContainer?.playMusic() }
        else { masterAudioPlayer?.play() }
    }
    func pauseMusic(){
        playButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        currentPhase = .Ready
        if playMode == .mixed{ mixedTrackContainer?.pauseMusic() }
        else{ masterAudioPlayer?.pause() }
    }
    func stopMusic(){
        if playMode == .mixed { mixedTrackContainer?.stopMusic() }
        else { masterAudioPlayer?.stop() }
        playButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
    }
    func toggle(to mode:Bool){
        stopMusic()
        if mode == true { playMode = .mixed} else { playMode = .master}
        stopMusic()
    }

    @IBAction func stopButtonHandler(_ sender: UIButton) {
        stopMusic()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}


extension PlayBarViewController{
    private enum Phase{
        case Ready
        case Playing
        case Recording
    }
    private enum PlayMode{
        case master
        case mixed
    }
}
