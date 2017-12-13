//
//  MasterWaveFormViewCell.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 11. 30..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit
import AudioKit
import AudioKitUI
import FDWaveformView
import NVActivityIndicatorView

class MasterWaveFormViewCell: UITableViewCell, FDWaveformViewDelegate {

//    @IBOutlet weak var audioPlot: EZAudioPlot!
    
    @IBOutlet weak private var activityIndicator: NVActivityIndicatorView!
 
    var masterAudioURL:URL?{
        willSet(newVal){
            let audioPlot = EZAudioPlot(frame:self.contentView.frame)
            audioPlot.shouldFill = true
            audioPlot.plotType = .buffer
            audioPlot.shouldMirror = true
            audioPlot.color = .orange
            self.addSubview(audioPlot)
            DispatchQueue.global().async {
                let file = EZAudioFile(url: newVal!)!
                let bufferLength:UInt32 = 512
                let waveData = file.getWaveformData(withNumberOfPoints: bufferLength)
                let buffer = waveData?.buffers[0]
                DispatchQueue.main.async {
                    audioPlot.updateBuffer(buffer, withBufferSize: bufferLength)
                    self.activityIndicator.stopAnimating()
                }
            }

//            waveForm.audioURL = newVal
        }
    }

//    func waveformViewDidRender(_ waveformView: FDWaveformView) {
//        activityIndicator.stopAnimating()
//    }

    override func awakeFromNib() {
        super.awakeFromNib()

//        waveForm.delegate = self
//        waveForm.wavesColor = .orange
//        waveForm.loadingInProgress = true
        activityIndicator.color = .orange
        activityIndicator.type = .audioEqualizer
        activityIndicator.startAnimating()
    }

}
