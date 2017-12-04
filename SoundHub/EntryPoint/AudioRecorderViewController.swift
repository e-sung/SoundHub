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

    @IBAction func cancleButtonHandler(_ sender: UIBarButtonItem) {
        AudioKit.stop()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var inputPlot: AKNodeOutputPlot!
    let mic = AKMicrophone()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputPlot.node = mic
        AudioKit.start()
    }
}
