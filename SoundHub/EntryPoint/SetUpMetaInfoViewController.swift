//
//  SetUpMetaInfoViewController.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 12. 5..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit
import AVFoundation
import AudioKit

class SetUpMetaInfoViewController: UIViewController{


    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var instrumentPicker: UIPickerView!
    @IBAction func confirmButtonHandler(_ sender: UIButton) {
        export(asset: player.audioFile.avAsset, to: self.exportURL, with: self.metadatas)
    }
    @IBAction func onTouchHandler(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    let instruments = ["Guitar", "Bass", "Drums", "Vocal", "Keyboard", "Others"]
    let genres = ["Rock", "Jazz", "Blues", "Pop" ]
    
    var player:AKAudioPlayer!
    var selectedInstrument:String!
    var selectedGenre:String!

    override func viewDidLoad() {
        super.viewDidLoad()
        instrumentPicker.delegate = self
        instrumentPicker.dataSource = self
        selectedInstrument = instruments[0]
        selectedGenre = genres[0]

        // Do any additional setup after loading the view.
    }
}

extension SetUpMetaInfoViewController{
    private var titleMetadata:AVMutableMetadataItem{
        get{
            let titleItem =  AVMutableMetadataItem()
            titleItem.identifier = AVMetadataIdentifier.commonIdentifierTitle
            titleItem.value = titleTF.text! as (NSCopying & NSObjectProtocol)?
            return titleItem
        }
    }
    private var artistMetaData:AVMutableMetadataItem{
        get{
            let artistItem = AVMutableMetadataItem()
            artistItem.identifier = AVMetadataIdentifier.commonIdentifierArtist
            artistItem.value = UserDefaults.standard.string(forKey: "nickName")! as (NSCopying & NSObjectProtocol)?
            return artistItem
        }
    }
    
    private var metadatas:[AVMetadataItem]{
        get{
            return [titleMetadata,artistMetaData]
        }
    }
    private var exportURL:URL{
        get{
            return URL(string: "\(titleTF.text!).m4a".trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), relativeTo: DataCenter.documentsDirectoryURL)!
        }
    }
}

extension SetUpMetaInfoViewController{
    private func export(asset:AVAsset, to url:URL, with metadatas:[AVMetadataItem]){
        if let session = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A){
            AVPlayerItem(url: exportURL).asset.metadata
            session.metadata = metadatas
            session.outputFileType = AVFileType.m4a
            session.outputURL = exportURL
            session.exportAsynchronously {
                DispatchQueue.main.async(execute: {self.showUploadVC()})
            }
        }else {
            print("AVAssetExportSession wasn't generated")
        }
    }
    
    private func showUploadVC(){
        let storyBoard = UIStoryboard(name: "Entry", bundle: nil)
        let audioUploadVC = storyBoard.instantiateViewController(withIdentifier: "DocumentViewController") as! AudioUploadViewController
        audioUploadVC.audioURL = exportURL
        audioUploadVC.genre = selectedGenre
        audioUploadVC.instrument = selectedInstrument
        present(audioUploadVC, animated: true, completion: nil)
    }
}

extension SetUpMetaInfoViewController:UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return component == 0 ? instruments.count : genres.count
    }
}

extension SetUpMetaInfoViewController:UIPickerViewDelegate{
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            selectedInstrument = instruments[row]
        }else{
            selectedGenre = genres[row]
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return instruments[row]
        }else{
            return genres[row]
        }
    }
}
