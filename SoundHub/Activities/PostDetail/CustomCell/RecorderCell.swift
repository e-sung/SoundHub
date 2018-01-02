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

    weak var delegate:RecorderCellDelegate?
    private var auManager: AKAudioUnitManager?
    private var availableEffects:[String] = []
    var postId:Int!
    var isActive = false
    var currentAU: AudioUnitGenericView?
    var currentAUindex:Int?

    @IBOutlet var audioUnitContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var audioUnitContainerFlowLayout: UICollectionView!
    @IBOutlet weak var auGenericViewContainer: UIScrollView!
    @IBOutlet private weak var recordButton: UIButton!
    @IBOutlet private weak var inputPlot: AKNodeOutputPlot!
    override func awakeFromNib() {
        super.awakeFromNib()
        audioUnitContainerFlowLayout.delegate = self
        audioUnitContainerFlowLayout.dataSource = self
        audioUnitContainerHeight.isActive = false
        audioUnitContainerFlowLayout.isHidden = true
        auGenericViewContainer.isHidden = true
        RecordConductor.main.connectMic(with: inputPlot)
        state = .readyToRecord
    }

    private func showAudioUnit(_ audioUnit: AVAudioUnit) {

        if currentAU != nil {
            currentAU?.removeFromSuperview()
        }

        currentAU = AudioUnitGenericView(au: audioUnit)
        auGenericViewContainer.addSubview(currentAU!)
        auGenericViewContainer.contentSize = currentAU!.frame.size

    }

    func activate() {
        RecordConductor.main.connectMic(with: inputPlot)
        auManager = AKAudioUnitManager()
        auManager?.delegate = self
        auManager?.requestEffects { (audioComponents) in
            for component in audioComponents {
                if component.name != ""{ self.availableEffects.append(component.name) }
            }
            self.audioUnitContainerFlowLayout.reloadData()
        }
        auManager?.input = RecordConductor.main.player
        auManager?.output = RecordConductor.main.mainMixer

        self.isActive = true
        state = .readyToRecord
        inputPlot.color = .orange
        RecordConductor.main.connectMic(with: inputPlot)
        audioUnitContainerHeight.isActive = true
        audioUnitContainerFlowLayout.isHidden = false
        auGenericViewContainer.isHidden = false
        self.contentView.backgroundColor = .black
    }

    func connectInputPlotToMic() { RecordConductor.main.connectMic(with: inputPlot) }

    func deActivate() {
        self.isActive = false
        if let auManager = auManager {
            if auManager.availableEffects.isEmpty == false { auManager.removeEffect(at: 0) }
        }
        audioUnitContainerHeight.isActive = false
        audioUnitContainerFlowLayout.isHidden = true
        auGenericViewContainer.isHidden = true
        self.contentView.backgroundColor = .gray
        inputPlot.color = .black
        DispatchQueue.global(qos: .userInitiated).async { RecordConductor.main.resetRecorder() }
    }

    @IBAction private func recordButtonHandler(_ sender: UIButton) {
        if User.isLoggedIn == false {
            delegate?.shouldRequireLogin()
            return
        }
        if self.isActive == false {
            self.deinitialize()
            delegate?.shouldBecomeActive()
        }else {
            switch state! {
            case .readyToRecord :
                makeRecordingState()
                delegate?.didStartRecording()
            case .recording :
                makeReadyToPlayState()
                delegate?.didStopRecording()
            case .readyToPlay :
                RecordConductor.main.playRecorded(looping: true)
                delegate?.didStartPlayingRecordedAudio()
                inputPlot.color = .orange
                inputPlot.node = RecordConductor.main.player
                recordButton.setTitle("확인", for: .normal)
                state = .playing
            case .playing :
                RecordConductor.main.player.stop()
                delegate?.didStoppedPlayingRecorededAudio()
                state = .readyToRecord
                recordButton.setTitle("녹음", for: .normal)
                let recordedDuration = RecordConductor.main.player != nil ? RecordConductor.main.player.audioFile.duration  : 0
                if recordedDuration > 0.0 {
                    delegate?.shouldShowAlert()
                    RecordConductor.main.stopRecording()
                    RecordConductor.main.connectMic(with: inputPlot)
                }
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

    func deinitialize() {
        inputPlot.node?.avAudioNode.removeTap(onBus: 0)
    }

    private func makeRecordingState() {
        if auManager?.input != RecordConductor.main.player {
            auManager?.connectEffects(firstNode: RecordConductor.main.player, lastNode: RecordConductor.main.mainMixer)
        }
        recordButton.setTitle("중지", for: .normal)
        inputPlot.color = .red
        state = .recording
        RecordConductor.main.startRecording()
    }

    private func makeReadyToPlayState() {
        recordButton.setTitle("듣기", for: .normal)
        state = .readyToPlay
        inputPlot.color = .orange
        RecordConductor.main.resetPlayer()
    }

}

extension RecorderCell:UICollectionViewDataSource {
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

extension RecorderCell:UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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

extension RecorderCell:AKAudioUnitManagerDelegate {
    func handleAudioUnitNotification(type: AKAudioUnitManager.Notification, object: Any?) {

    }

    func handleEffectAdded(at auIndex: Int) {
        if RecordConductor.main.player.isStarted {
            RecordConductor.main.player.stop()
            RecordConductor.main.player.start()
        }
        if let au = auManager!.effectsChain[auIndex] {
            showAudioUnit(au)
        }
    }

    func handleEffectRemoved(at auIndex: Int) {
        print("Effect removed")
    }

}

protocol RecorderCellDelegate: class {
    func uploadDidFinished(with post:Post?)
    func shouldShowAlert()
    func shouldBecomeActive()
    func shouldRequireLogin()
    func didStartRecording()
    func didStopRecording()
    func didStartPlayingRecordedAudio()
    func didStoppedPlayingRecorededAudio()
}
