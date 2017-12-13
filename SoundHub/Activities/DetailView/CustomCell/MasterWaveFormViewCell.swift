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
    var audioPlot:EZAudioPlot?
    var masterAudioURL:URL?{
        didSet(oldVal){
            if audioPlot == nil {

                let file = try! AKAudioFile(forReading: masterAudioURL!)
                let floatfile.floatChannelData
                let player = try! AKAudioPlayer(file: file)
                let akpot = AKNodeOutputPlot(player, frame: self.contentView.frame, bufferSize: 128)
                akpot.node = player
                
                contentView.addSubview(akpot)
                akpot.plotType = .rolling
                akpot.shouldFill = true
                akpot.shouldMirror = true
                akpot.color = .orange
                player.play()

                
                
//                audioPlot = EZAudioPlot(frame:self.contentView.frame)
//                audioPlot!.shouldFill = true
//                audioPlot!.plotType = .buffer
//                audioPlot!.shouldMirror = true
//                audioPlot!.color = .orange
//                DispatchQueue.global(qos: .userInteractive).async {
//                    let file = EZAudioFile(url: self.masterAudioURL!)!
//                    let bufferLength:UInt32 = 128
//                    let waveData = file.getWaveformData(withNumberOfPoints: bufferLength)
//                    let buffer = waveData?.buffers[0]
//
//                    self.audioPlot!.updateBuffer(buffer, withBufferSize: bufferLength)
//                    DispatchQueue.main.async {
//                        self.activityIndicator.stopAnimating()
//                        self.addSubview(self.audioPlot!)
//                    }
//                }

//                DispatchQueue.global().async {
//
//                    DispatchQueue.main.async {
//
//
//                    }
//                }
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
