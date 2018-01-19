//
//  RecorderView.swift
//  SoundHub
//
//  Created by esung on 2018. 1. 18..
//  Copyright © 2018년 류성두. All rights reserved.
//

import UIKit
import AudioKit
import AudioKitUI

class RecorderView: UIView {

    // MARK: IBoutlets
    @IBOutlet weak private var recordButton: UIButton!
    @IBOutlet weak private var inputPlot: AKNodeOutputPlot!
    @IBOutlet weak private var audioUnitContainerFlowLayout: UICollectionView!
    @IBOutlet weak private var auGenericViewContainer: UIScrollView!
    
    // MARK: StoredProperties
    var currentAU: AudioUnitGenericView?
    var availableEffects = RecordConductor.main.availableEffects
    var auManager = RecordConductor.main.auManager
    var currentAUindex: Int?
    
    var isAudioUnitHidden: Bool{
        get{ return audioUnitContainerFlowLayout.isHidden }
        set(newVal){ audioUnitContainerFlowLayout.isHidden = newVal }
    }
    
    var colorOfPlot: UIColor{
        get{ return inputPlot.color }
        set(newVal){ inputPlot.color = newVal }
    }
    
    func bootUP(){
        RecordConductor.main.refresh()
        RecordConductor.main.connectMic(with: inputPlot)
        RecordConductor.main.applyAUManager()
        
        
        audioUnitContainerFlowLayout.delegate = self
        audioUnitContainerFlowLayout.dataSource = self
    }

    func deactivate(){
        inputPlot.node?.avAudioNode.removeTap(onBus: 0)
        if RecordConductor.main.auManager.effectsCount != 0 {
            RecordConductor.main.auManager.removeEffect(at: 0)
        }
    }
    
    func showAudioUnit(_ audioUnit: AVAudioUnit) {
        
        if currentAU != nil { currentAU?.removeFromSuperview() }
        
        currentAU = AudioUnitGenericView(au: audioUnit)
        auGenericViewContainer.addSubview(currentAU!)
        auGenericViewContainer.contentSize = currentAU!.frame.size
    }
    
    func makeReadyToRecordState(){
        RecordConductor.main.player.stop()
        RecordConductor.main.connectMic(with: inputPlot)
        inputPlot.color = .orange
        recordButton.setTitle("녹음", for: .normal)
    }
    
    func makeRecordingState() {
        recordButton.setTitle("그만", for: .normal)
        inputPlot.color = .red
        RecordConductor.main.startRecording()
    }
    
    func makeReadyToPlayState() {
        recordButton.setTitle("들어보기", for: .normal)
        inputPlot.color = .orange
        RecordConductor.main.stopRecording()
        RecordConductor.main.resetPlayer()
    }
    
    func makePlayingState(){
        RecordConductor.main.playRecorded(looping: true)
        inputPlot.color = .orange
        inputPlot.node = RecordConductor.main.player
        recordButton.setTitle("그만 듣고 업로드하기", for: .normal)
    }
}

// MARK: UICollectionViewDataSource
extension RecorderView: UICollectionViewDataSource {
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
extension RecorderView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        auManager.removeEffect(at: 0)
        auManager.insertAudioUnit(name: availableEffects[indexPath.item], at: 0)
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
