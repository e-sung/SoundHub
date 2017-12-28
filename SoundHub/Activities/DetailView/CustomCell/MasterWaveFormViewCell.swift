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
        plot?.progress = progress
    }
    
    func didFinishRendering() {
        DispatchQueue.main.async {
            self.activityLB.isHidden = true
            self.activityIndicator.stopAnimating()
        }
    }

    @IBOutlet weak var activityLB: UILabel!
    @IBOutlet weak private var activityIndicator: NVActivityIndicatorView!
    private var plot:NCSoundHistogram?
    var masterAudioURL:URL?{
        didSet(oldVal){
            DispatchQueue.main.async {
                self.activityLB.text = "그리는 중"
                self.plot = NCSoundHistogram(frame: self.contentView.frame)
                self.plot!.delegate = self
                self.plot!.waveColor = UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 0.5)
                self.plot!.progressColor = UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)
                self.plot!.drawSpaces = true
                self.plot!.barLineWidth = 2.5
                self.contentView.addSubview(self.plot!)
                DispatchQueue.global(qos: .userInteractive).async {
                    self.plot?.soundURL = self.masterAudioURL
                }
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        activityIndicator.color = .orange
        activityIndicator.type = .audioEqualizer
        activityIndicator.startAnimating()
    }
}
