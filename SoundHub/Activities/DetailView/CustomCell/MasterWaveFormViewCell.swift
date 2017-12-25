//
//  MasterWaveFormViewCell.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 11. 30..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class MasterWaveFormViewCell: UITableViewCell, NCSoundHistogramDelegate {
    
    func reflect(progress:Float){
//        plot?.progress = progress
    }
    
    func didFinishRendering() {
//        DispatchQueue.main.async {
//            self.activityIndicator.stopAnimating()
//        }
    }

    @IBOutlet weak private var activityIndicator: NVActivityIndicatorView!
    private var plot:NCSoundHistogram?
    var masterAudioURL:URL?{
        didSet(oldVal){
//            DispatchQueue.main.async {
//                self.plot = NCSoundHistogram(frame: self.contentView.frame)
//                self.plot!.delegate = self
//                self.plot!.waveColor = .orange
//                self.plot!.progressColor = .green
//                self.plot!.drawSpaces = true
//                self.plot!.barLineWidth = 2.5
//                self.contentView.addSubview(self.plot!)
//            }
        }
    }
    func renderWave(){
//        DispatchQueue.global(qos: .userInteractive).async {
//            self.plot?.soundURL = self.masterAudioURL
//        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
//        activityIndicator.color = .orange
//        activityIndicator.type = .audioEqualizer
//        activityIndicator.startAnimating()
    }
}
