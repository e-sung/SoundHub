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
    @IBOutlet weak private var recordButton: UIButton!
    @IBOutlet weak private var inputPlot: AKNodeOutputPlot!
    @IBOutlet weak private var audioUnitContainerFlowLayout: UICollectionView!
    @IBOutlet weak private var auGenericViewContainer: UIScrollView!

    @IBAction private func cancleButtonHandler(_ sender: UIButton) {
        self.dismiss(animated: true) { RecordConductor.main.resetRecorder() }
    }

    @IBAction private func recordButtonHandler(_ sender: UIButton) {

        switch state! {
        case .readyToRecord :
            makeRecordingState()
        case .recording :
            makeReadyToPlayState()
        case .readyToPlay :
            RecordConductor.main.playRecorded(looping: true)
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
                setUpMetaInfoUI()
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

    // MARK: StoredProperties
    private var state: State!
    private var auManager: AKAudioUnitManager?
    private var availableEffects: [String] = []
    private var currentAU: AudioUnitGenericView?
    private var currentAUindex: Int?

    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        audioUnitContainerFlowLayout.delegate = self
        audioUnitContainerFlowLayout.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        state = .readyToRecord
        RecordConductor.main.resetRecorder()
        RecordConductor.main.connectMic(with: inputPlot)
        RecordConductor.main.resetPlayer()
        activateAUManager()
    }

    override func viewWillDisappear(_ animated: Bool) {
        inputPlot.node?.avAudioNode.removeTap(onBus: 0)
        if let auManager = auManager {
            if auManager.availableEffects.isEmpty == false { auManager.removeEffect(at: 0) }
        }
    }
}

// MARK: UICollectionViewDataSource
extension AudioRecorderViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return availableEffects.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AUCell", for: indexPath) as! AUCell
        let effectTitle = String(availableEffects[indexPath.item].dropFirst(2)).brokenAtCaptial
        cell.backgroundColor = AUCell.defaultBackgroundColor
        cell.titleLB.textColor = AUCell.defaultTextColor
        cell.titleLB.text = effectTitle
        return cell
    }
}

// MARK: UICollectionViewDelegate
extension AudioRecorderViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        auManager?.removeEffect(at: 0)
        auManager?.insertAudioUnit(name: availableEffects[indexPath.item], at: 0)
        currentAUindex = indexPath.item
        let cell = collectionView.cellForItem(at: indexPath) as! AUCell
        cell.backgroundColor = AUCell.selectedBackgroundColor
        cell.titleLB.textColor = AUCell.selectedTextColor
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? AUCell {
            cell.backgroundColor = AUCell.defaultBackgroundColor
            cell.titleLB.textColor = AUCell.defaultTextColor
        }
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? AUCell {
            cell.backgroundColor = AUCell.defaultBackgroundColor
            cell.titleLB.textColor = AUCell.defaultTextColor
        }
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let currentAuIndex = currentAUindex else { return }
        if let cell = cell as? AUCell {
            if currentAuIndex == indexPath.item {
                cell.backgroundColor = AUCell.selectedBackgroundColor
                cell.titleLB.textColor = AUCell.selectedTextColor
            }
        }
    }
}

// MARK: AKAudioUnitManagerDelegate
extension AudioRecorderViewController: AKAudioUnitManagerDelegate {
    func handleAudioUnitNotification(type: AKAudioUnitManager.Notification, object: Any?) {
    }

    func handleEffectAdded(at auIndex: Int) {
        if let au = auManager!.effectsChain[auIndex] { showAudioUnit(au) }
    }

    func handleEffectRemoved(at auIndex: Int) { print("Effect removed") }

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

    private func makeRecordingState() {
        if let auManager = auManager { RecordConductor.main.apply(auManager) }
        recordButton.setTitle("그만 녹음하기", for: .normal)
        inputPlot.color = .red
        state = .recording
        RecordConductor.main.startRecording()
    }

    private func makeReadyToPlayState() {
        recordButton.setTitle("들어보기", for: .normal)
        state = .readyToPlay
        inputPlot.color = .orange
        RecordConductor.main.stopRecording()
        RecordConductor.main.resetPlayer()
    }

    private func activateAUManager() {
        auManager = AKAudioUnitManager()
        auManager?.delegate = self
        auManager?.requestEffects { (audioComponents) in
            for component in audioComponents {
                if component.name != ""{ self.availableEffects.append(component.name) }
            }
            self.audioUnitContainerFlowLayout.reloadData()
        }
    }

    private func showAudioUnit(_ audioUnit: AVAudioUnit) {

        if currentAU != nil { currentAU?.removeFromSuperview() }

        currentAU = AudioUnitGenericView(au: audioUnit)
        auGenericViewContainer.addSubview(currentAU!)
        auGenericViewContainer.contentSize = currentAU!.frame.size
    }
}
