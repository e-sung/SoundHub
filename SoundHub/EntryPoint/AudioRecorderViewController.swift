//
//  AudioRecorderViewController.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 12. 4..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit
import AudioKit
import AudioKitUI

class AudioRecorderViewController: UIViewController {
    @IBOutlet weak var inputPlot: AKNodeOutputPlot!
    let mic = AKMicrophone()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputPlot.node = mic
        AudioKit.start()
    }
}
