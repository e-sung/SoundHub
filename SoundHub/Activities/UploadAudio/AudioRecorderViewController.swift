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

class AudioRecorderViewController: UIViewController, RecorderViewDelegate {
    
    // MARK: IBoutlets
    @IBOutlet weak private var recorderView:RecorderView!

    @IBAction private func cancleButtonHandler(_ sender: UIButton) {
        self.dismiss(animated: true) { RecordConductor.main.resetRecorder() }
    }

    @IBAction private func recordButtonHandler(_ sender: UIButton) {
        recorderView.changeState()
    }

    // MARK: LifeCycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        RecordConductor.main.recorderView = self.recorderView
        recorderView.delegate = self
        recorderView.bootUP()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        recorderView.deactivate()
    }
    
    func shouldUploadRecorded() {
        let recordedDuration = RecordConductor.main.player != nil ? RecordConductor.main.player.audioFile.duration : 0
        if recordedDuration > 0.0 { setUpMetaInfoUI() }
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
