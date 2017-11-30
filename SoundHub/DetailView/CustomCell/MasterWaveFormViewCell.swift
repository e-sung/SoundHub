//
//  MasterWaveFormViewCell.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 11. 30..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit
import FDWaveformView

class MasterWaveFormViewCell: UITableViewCell, FDWaveformViewDelegate {

    @IBOutlet weak var waveForm: FDWaveformView!
    let musicURL = URL(string: "https://s3.ap-northeast-2.amazonaws.com/che1-soundhub/media/author_tracks/The_Shortest_Straw_-_Drums.mp3")!

    func downloadFile(from audioURL:URL) {
        
        // then lets create your document folder url
        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // lets create your destination file url
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(musicURL.lastPathComponent)
        print(destinationUrl)
        
        // to check if it exists before downloading it
        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            print("The file already exists at path")
            self.waveForm.audioURL = destinationUrl
        } else {
            URLSession.shared.downloadTask(with: audioURL, completionHandler: { (location, response, error) -> Void in
                guard let location = location, error == nil else { return }
                do {
                    // after downloading your file you need to move it to your destination url
                    try FileManager.default.moveItem(at: location, to: destinationUrl)
                    self.waveForm.audioURL = destinationUrl
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }).resume()
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        downloadFile(from: musicURL)
        waveForm.delegate = self
        waveForm.wavesColor = .orange
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

 
    

}
