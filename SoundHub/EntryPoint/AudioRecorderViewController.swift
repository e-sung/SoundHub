//
//  AudioRecorderViewController.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 12. 4..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit
import AVFoundation
import AudioKit
import AudioKitUI

class AudioRecorderViewController: UIViewController {

    
    // MARK: IBoutlets
    @IBOutlet weak private var recordButton: UIButton!
    @IBOutlet weak private var inputPlot: AKNodeOutputPlot!
    
    // MARK: IBActions
    @IBAction private func onScreenTouchHandler(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func onCancelHandler(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func recordButtonHandler(_ sender: UIButton) {
        
        switch state! {
        case .readyToRecord :
            makeRecordingState()
        case .recording :
            makeReadyToPlayState()
        case .readyToPlay :
            RecordConductor.main.player.play()
            inputPlot.color = .orange
            inputPlot.node = RecordConductor.main.player
            recordButton.setTitle("그만 듣고 업로드하기", for: .normal)
            state = .playing
        case .playing :
            RecordConductor.main.player.stop()
            state = .readyToRecord
            recordButton.setTitle("녹음하기", for: .normal)
            let recordedDuration = RecordConductor.main.player != nil ? RecordConductor.main.player.audioFile.duration  : 0
            if recordedDuration > 0.0 {
                RecordConductor.main.recorder.stop()
                showMetaInfoSetUpVC()
            }
        }
    }

    // MARK: Private Enum
    private enum State {
        case readyToRecord
        case recording
        case readyToPlay
        case playing
    }
    
    private var state:State!

    // MARK: LifeCycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        state = .readyToRecord
        inputPlot.node = RecordConductor.main.mic
    }

}

// MARK: Helper Functions
extension AudioRecorderViewController{

    private func showMetaInfoSetUpVC(){
        let storyBoard = UIStoryboard(name: "Entry", bundle: nil)
        let metaInfoSetUpVC = storyBoard.instantiateViewController(withIdentifier: "SetUpMetaInfoViewController") as! SetUpMetaInfoViewController
        metaInfoSetUpVC.player = RecordConductor.main.player
        present(metaInfoSetUpVC, animated: true, completion: nil)
    }
    
    private func makeRecordingState(){
        recordButton.setTitle("그만 녹음하기", for: .normal)
        inputPlot.color = .red
        state = .recording
        RecordConductor.main.startRecording()
    }
    
    private func makeReadyToPlayState(){
        recordButton.setTitle("들어보기", for: .normal)
        state = .readyToPlay
        inputPlot.color = .orange
        RecordConductor.main.stopRecording()
    }
}
