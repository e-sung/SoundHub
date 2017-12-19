//
//  SelectInstrmuentViewController.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 12. 19..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit
import AVFoundation
class SelectInstrmuentViewController: UIViewController {
    var postId:Int!
    var selectedInstrument = "Vocal"
    @IBAction func confirmButtonHandler(_ sender: UIButton) {
        let asset = RecordConductor.main.player.audioFile.avAsset
        RecordConductor.main.exportComment(asset: asset, completion: { (outputURL) in
            NetworkController.main.uploadAudioComment(In: outputURL, to: self.postId, instrument: self.selectedInstrument, completion: {
                NetworkController.main.fetchPost(id: self.postId, completion: { (post) in
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "unwindToDetail", sender: post)
                    }
                })
            })
        })
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let post = sender as? Post{
            if let nextVC = segue.destination as? DetailViewController{
                nextVC.post = post
            }
        }
    }
    @IBOutlet weak var instrumentSelector: UIPickerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        instrumentSelector.delegate = self
        instrumentSelector.dataSource = self
    }
}

extension SelectInstrmuentViewController:UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Instrument.cases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Instrument.cases[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedInstrument = Instrument.cases[row]
    }
    
}
