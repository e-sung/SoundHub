//
//  RecorderCell.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 12. 10..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit
import AudioKitUI

class RecorderCell: UITableViewCell {

    var delegate:RecorderCellDelegate?
    var postId:Int!
    @IBOutlet private weak var recordButton: UIButton!
    @IBOutlet private weak var inputPlot: AKNodeOutputPlot!
    override func awakeFromNib() {
        super.awakeFromNib()
        state = .readyToRecord
        inputPlot.node = RecordConductor.main.mic
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
            recordButton.setTitle("확인", for: .normal)
            state = .playing
        case .playing :
            RecordConductor.main.player.stop()
            state = .readyToRecord
            recordButton.setTitle("녹음", for: .normal)
            let recordedDuration = RecordConductor.main.player != nil ? RecordConductor.main.player.audioFile.duration  : 0
            if recordedDuration > 0.0 {
                delegate?.shouldShowAlert()
                RecordConductor.main.recorder.stop()
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
    
    func deinitialize(){
        inputPlot.node?.avAudioNode.removeTap(onBus: 0)
    }

    private func makeRecordingState(){
        recordButton.setTitle("중지", for: .normal)
        inputPlot.color = .red
        state = .recording
//        playBarVC.playMusic()
        RecordConductor.main.startRecording()
    }
    
    private func makeReadyToPlayState(){
        recordButton.setTitle("듣기", for: .normal)
        state = .readyToPlay
        inputPlot.color = .orange
//        playBarVC.pauseMusic()
        RecordConductor.main.stopRecording()
    }
    
}

protocol RecorderCellDelegate {
    func uploadDidFinished(with post:Post?)->Void
    func shouldShowAlert()->Void
}
