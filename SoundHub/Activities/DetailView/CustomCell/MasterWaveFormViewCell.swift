//
//  MasterWaveFormViewCell.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 11. 30..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit
import FDWaveformView
import NVActivityIndicatorView

class MasterWaveFormViewCell: UITableViewCell, FDWaveformViewDelegate {

    @IBOutlet weak private var activityIndicator: NVActivityIndicatorView!
    @IBOutlet weak private var waveForm: FDWaveformView!
    var masterAudioURL:URL?{
        willSet(newVal){
            waveForm.audioURL = newVal
        }
    }

    func waveformViewDidRender(_ waveformView: FDWaveformView) {
        activityIndicator.stopAnimating()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        waveForm.delegate = self
        waveForm.wavesColor = .orange
        waveForm.loadingInProgress = true
        activityIndicator.color = .orange
        activityIndicator.type = .audioEqualizer
        activityIndicator.startAnimating()
    }

}
