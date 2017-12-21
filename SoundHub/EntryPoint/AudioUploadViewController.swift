
//
//  AudioUploadViewController.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 12. 1..
//  Copyright © 2017년 류성두. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class AudioUploadViewController: UIViewController {
    
    var audioURL:URL!
    var genre:String = "Pop"
    var instrument:String = "Vocal"
    @IBOutlet weak private var albumArt: UIImageView!
    @IBOutlet weak private var audioTitleLB: UILabel!
    @IBOutlet weak private var authorNameLB: UILabel!
    @IBAction private func cancelHandler(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func uploadHandler(_ sender: UIButton) {
        NetworkController.main.uploadAudio(In: audioURL, genre: genre, instrument: instrument) {
            self.dismissWith(depth: 3, from: self)
        }
    }

    private func setUpUI(with audio:AVPlayerItem){
        for item in audio.asset.metadata{
            if let key = item.commonKey, let value = item.value {
                if key == .commonKeyArtwork, let data = value as? Data{
                    albumArt.image = UIImage(data: data)
                }
                else if key == .commonKeyTitle {
                    audioTitleLB.text = value as? String
                }
                else if key == .commonKeyArtist {
                    authorNameLB.text = value as? String
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let playerItem = AVPlayerItem(url: audioURL)
        audioTitleLB.text = "Untitled"
        authorNameLB.text = UserDefaults.standard.string(forKey: nickname)
        setUpUI(with: playerItem)
    }
}
