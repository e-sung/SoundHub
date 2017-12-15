//
//  MasterWaveFormViewCell.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 11. 30..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit
import NCSoundHistogram
import NVActivityIndicatorView

class MasterWaveFormViewCell: UITableViewCell, NCSoundHistogramDelegate {
    
    func reflect(progress:Float){
        plot?.progress = progress
    }
    
    func didFinishRendering() {
        activityIndicator.stopAnimating()
    }

    @IBOutlet weak private var activityIndicator: NVActivityIndicatorView!
    private var plot:NCSoundHistogram?
    var masterAudioURL:URL?{
        didSet(oldVal){
            plot = NCSoundHistogram(frame: contentView.frame)
            plot!.delegate = self
            plot!.waveColor = .orange
            plot!.progressColor = .green
            plot!.drawSpaces = true
            plot!.barLineWidth = 2.5
            contentView.addSubview(plot!)
        }
    }
    func renderWave(){
        plot?.soundURL = masterAudioURL
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        activityIndicator.color = .orange
        activityIndicator.type = .audioEqualizer
        activityIndicator.startAnimating()
    }
}
