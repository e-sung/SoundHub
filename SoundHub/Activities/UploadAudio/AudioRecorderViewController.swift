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
import ActionSheetPicker_3_0

class AudioRecorderViewController: UIViewController {

    // MARK: IBoutlets
    @IBOutlet weak private var recorderView:RecorderView!

    @IBAction private func cancleButtonHandler(_ sender: UIButton) {
        self.dismiss(animated: true) { RecordConductor.main.resetRecorder() }
    }

    @IBAction private func recordButtonHandler(_ sender: UIButton) {
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
            if recordedDuration > 0.0 { setUpMetaInfoUI() }
        }
    }

    // MARK: Private Enum
    private enum State {
        case readyToRecord
        case recording
        case readyToPlay
        case playing
    }

    // MARK: StoredProperties
    private var state: State!

    // MARK: LifeCycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        state = .readyToRecord
        RecordConductor.main.recorderView = self.recorderView
        recorderView.bootUP()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        recorderView.deactivate()
    }
}

// MARK: Helper Functions
extension AudioRecorderViewController {

    private func setUpMetaInfoUI() {
        let storyBoard = UIStoryboard(name: "UploadAudio", bundle: nil)
        let audioUploadVC = storyBoard.instantiateViewController(withIdentifier: "DocumentViewController") as! AudioUploadViewController

        ActionSheetStringPicker.show(withTitle: "어떤 악기인가요?", rows: Instrument.cases, initialSelection: 0, doneBlock: { (picker, row, result) in

            audioUploadVC.instrument = Instrument.cases[row]
            ActionSheetStringPicker.show(withTitle: "어떤 장르인가요?", rows: Genre.cases, initialSelection: 0, doneBlock: { (picker, row, result) in
                audioUploadVC.genre = Genre.cases[row]
                self.present(audioUploadVC, animated: true, completion: nil)
            }, cancel: { (picker) in
            }, origin: self.view)
        }, cancel: { (picker) in
        }, origin: self.view)
    }
}
