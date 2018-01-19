//
//  RecorderCell.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 12. 10..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit
import AudioKitUI

class RecorderCell: UITableViewCell, RecorderViewDelegate {

    weak var delegate: RecorderCellDelegate?
    private var auManager = RecordConductor.main.auManager
    private var availableEffects: [String] = []
    var postId: Int!
    var isActive:Bool{
        get{ return _isActive }
        set(newVal){
            _isActive = newVal
            shouldShowAudioUnits(newVal)
            if newVal { activate() }
            else{ deactivate() }
        }
    }
    var _isActive = false

    @IBOutlet weak var recorderView: RecorderView!
    @IBOutlet var audioUnitContainerHeight: NSLayoutConstraint!
    
    private func activate(){
        RecordConductor.main.recorderView = self.recorderView
        recorderView.bootUP()
        recorderView.backgroundColor = .black
    }
    private func deactivate(){
        if auManager.availableEffects.isEmpty == false { auManager.removeEffect(at: 0) }
        recorderView.deactivate()
        recorderView.backgroundColor = .gray
        recorderView.colorOfPlot = .black
        DispatchQueue.global(qos: .userInitiated).async { RecordConductor.main.refresh() }
    }
    
    private func shouldShowAudioUnits(_ value:Bool){
        audioUnitContainerHeight.isActive = value
        recorderView.isAudioUnitHidden = !value
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        shouldShowAudioUnits(false)
        recorderView.bootUP()
        recorderView.delegate = self
    }

    @IBAction private func recordButtonHandler(_ sender: UIButton) {
        if User.isLoggedIn == false { delegate?.shouldRequireLogin(); return }
        if self.isActive == false { delegate?.shouldBecomeActive(); return }
        recorderView.changeState()
    }
    
    func shouldUploadRecorded() {
        let recordedDuration = RecordConductor.main.player != nil ? RecordConductor.main.player.audioFile.duration : 0
        if recordedDuration > 0.0 { delegate?.shouldShowAlert() }
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
