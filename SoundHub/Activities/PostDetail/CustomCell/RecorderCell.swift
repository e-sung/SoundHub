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

    weak var delegate: RecorderCellDelegate?
    private var auManager = RecordConductor.main.auManager
    private var availableEffects: [String] = []
    var postId: Int!
    var isActive = false

    @IBOutlet weak var recorderView: RecorderView!
    @IBOutlet var audioUnitContainerHeight: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        audioUnitContainerHeight.isActive = false
        recorderView.isAudioUnitHidden = true
        state = .readyToRecord
    }

    func activate() {
        self.isActive = true
        state = .readyToRecord
        recorderView.makeReadyToRecordState()
        
        audioUnitContainerHeight.isActive = true
        recorderView.isAudioUnitHidden = false
        recorderView.backgroundColor = .black
    }

    func deActivate() {
        self.isActive = false
        if auManager.availableEffects.isEmpty == false { auManager.removeEffect(at: 0) }
        audioUnitContainerHeight.isActive = false
        recorderView.isAudioUnitHidden = true
        recorderView.backgroundColor = .gray
        recorderView.colorOfPlot = .black
        DispatchQueue.global(qos: .userInitiated).async { RecordConductor.main.refresh() }
    }

    @IBAction private func recordButtonHandler(_ sender: UIButton) {
        if User.isLoggedIn == false { delegate?.shouldRequireLogin(); return }
        if self.isActive == false {
            self.deinitialize()
            delegate?.shouldBecomeActive()
            return
        }
        switch state! {
        case .readyToRecord :
            state = .recording
            recorderView.makeRecordingState()
        case .recording :
            state = .readyToPlay
            recorderView.makeReadyToPlayState()
        case .readyToPlay :
            state = .playing
            recorderView.makePlayingState()
        case .playing :
            state = .readyToRecord
            recorderView.makeReadyToRecordState()
            let recordedDuration = RecordConductor.main.player != nil ? RecordConductor.main.player.audioFile.duration  : 0
            if recordedDuration > 0.0 {
                delegate?.shouldShowAlert()
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

    private var state: State!

    func deinitialize() {
        
        recorderView.deactivate()
    }
}

protocol RecorderCellDelegate: class {
    func uploadDidFinished(with post: Post?)
    func shouldShowAlert()
    func shouldBecomeActive()
    func shouldRequireLogin()
    func didStartRecording()
    func didStopRecording()
    func didStartPlayingRecordedAudio()
    func didStoppedPlayingRecorededAudio()
}
