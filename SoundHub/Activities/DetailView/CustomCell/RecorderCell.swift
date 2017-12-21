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
    var auManager: AKAudioUnitManager!
    private var availableEffects:[String] = []
    var postId:Int!
    var isActive = false
    
    @IBOutlet weak var audioUnitContainerFlowLayout: UICollectionView!
    @IBOutlet private weak var recordButton: UIButton!
    @IBOutlet private weak var inputPlot: AKNodeOutputPlot!
    override func awakeFromNib() {
        super.awakeFromNib()
        audioUnitContainerFlowLayout.delegate = self
        audioUnitContainerFlowLayout.dataSource = self
        audioUnitContainerFlowLayout.isHidden = true
        
        inputPlot.node = RecordConductor.main.mic
        
        auManager = AKAudioUnitManager()
        auManager.delegate = self
        auManager.requestEffects { (audioComponents) in
            for component in audioComponents{
                if component.name != ""{
                    self.availableEffects.append(component.name)
                }
            }
            self.audioUnitContainerFlowLayout.reloadData()
        }
        auManager.input = RecordConductor.main.player
        auManager.output = RecordConductor.main.mainMixer
        
        state = .readyToRecord
    }
    
    func activate(){
        self.isActive = true
        state = .readyToRecord
        inputPlot.node = RecordConductor.main.mic
        audioUnitContainerFlowLayout.isHidden = false
        self.contentView.backgroundColor = .white
    }
    
    func deActivate(){
        self.isActive = false
        audioUnitContainerFlowLayout.isHidden = true
    }
    
    @IBAction private func recordButtonHandler(_ sender: UIButton) {
        if self.isActive == false{
            self.deinitialize()
            delegate?.shouldBecomeActive()
        }else {
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
        if auManager.input != RecordConductor.main.player {
            auManager.connectEffects(firstNode: RecordConductor.main.player, lastNode: RecordConductor.main.mainMixer)
        }
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

extension RecorderCell:UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return availableEffects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AUCell", for: indexPath) as! AUCell
        cell.titleLB.text = availableEffects[indexPath.item]
        return cell
    }
    
}

extension RecorderCell:UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        auManager.removeEffect(at: 0)
        auManager.insertAudioUnit(name: availableEffects[indexPath.item], at: 0)
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.contentView.backgroundColor = .green
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.contentView.backgroundColor = .orange
    }
}

extension RecorderCell:AKAudioUnitManagerDelegate{
    func handleAudioUnitNotification(type: AKAudioUnitManager.Notification, object: Any?) {
        
    }
    
    func handleEffectAdded(at auIndex: Int) {
        if RecordConductor.main.player.isStarted {
            RecordConductor.main.player.stop()
            RecordConductor.main.player.start()
        }
    }
    
    func handleEffectRemoved(at auIndex: Int) {
        print("Effect removed")
    }
 
}

protocol RecorderCellDelegate {
    func uploadDidFinished(with post:Post?)->Void
    func shouldShowAlert()->Void
    func shouldBecomeActive()->Void
}
