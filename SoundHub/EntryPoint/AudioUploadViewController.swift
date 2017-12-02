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
    
    @IBOutlet weak var albumArt: UIImageView!
    @IBOutlet weak var audioTitleLB: UILabel!
    @IBOutlet weak var authorNameLB: UILabel!
    @IBAction func cancelHandler(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func uploadHandler(_ sender: UIButton) {
        var request = URLRequest(url: URL(string: "https://soundhub.che1.co.kr/post/")!)
        request.addValue("Token 28a286c348adf86e24908cb972f26f0491f4e951", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
//        request.setValue(audioURL.lastPathComponent, forHTTPHeaderField: "author_track")
//        request.set
//
//
//        let task = session.uploadTask(with: request, fromFile: file)
//        task.resume()
//
//
//        let audio = FileManager.default.contents(atPath: audioURL.path)
//        struct MusicUploadRequest:Codable{
//            let title:String
//            let author_track:Data
//        }
//        let body = MusicUploadRequest(title: audioTitleLB.text!, author_track: audio!)
//        guard let requestBody = try? JSONEncoder().encode(body) else {
//            print("=============")
//            print("Encoding failed")
//            return
//        }
//        request.httpBody = requestBody
//        URLSession.shared.uploadTask(withStreamedRequest: request)
    }
    var audioURL:URL!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let playerItem = AVPlayerItem(url: audioURL)
        for item in playerItem.asset.metadata{
            if item.commonKey == nil{
                continue
            }

            if let key = item.commonKey, let value = item.value {
                if key == .commonKeyArtwork{
                    if let audioImage = UIImage(data: value as! Data){
                        albumArt.image = audioImage
                    }
                }
                else if key == .commonKeyTitle {
                    audioTitleLB.text = value as? String
                }else if key == .commonKeyArtist {
                    authorNameLB.text = value as? String
                }
            }
        }

    }

}
