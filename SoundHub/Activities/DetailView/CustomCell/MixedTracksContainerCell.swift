//
//  MixedTracksContainerCell.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 12. 8..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit
import AVFoundation

class MixedTracksContainerCell: UITableViewCell{
    
    var allComments:[String:[Comment]]?
    
    var mixedAudioPlayers:[String:[AVPlayer]]!
    var mixedAudioLocalURLs:[String:[URL]]!
//    {
//        didSet(oldVal){
//            guard let currentInstrument = currentInstrument else { return }
//            if let audioURL = mixedAudioLocalURLs[currentInstrument]?.last{
//                mixedAudioPlayers[currentInstrument]!.append(AVPlayer(url: audioURL))
//            }
//        }
//    }


    @IBOutlet weak var commentTV: UITableView!
    
    func setUpAudio(){
        guard let allComments = allComments else { return }
        for instrument in Instrument.cases{
            if allComments.keys.contains(instrument){
                fetchAudios(of: instrument, In: allComments[instrument]!)
            }
        }
    }
    
    private func fetchAudios(of instrument:String, In comments:[Comment]){
        for comment in comments{
            fetchAudio(of: instrument, In: comment)
        }
    }
    
    private func fetchAudio(of instrument:String, In comment:Comment){
        let remoteURL = URL(string: comment.comment_track.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)!, relativeTo: NetworkController.main.baseMediaURL)!
        NetworkController.main.downloadAudio(from: remoteURL) { (localURL) in
            self.mixedAudioPlayers[instrument]!.append( AVPlayer(url: localURL))
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commentTV.delegate = self
        commentTV.dataSource = self
        mixedAudioPlayers = initializeDic(of: AVPlayer.self, with: Instrument.cases)
        mixedAudioLocalURLs = initializeDic(of: URL.self, with: Instrument.cases)
        
    }

}

extension MixedTracksContainerCell:UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return Instrument.cases.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let instrument = Instrument.cases[section]
        if let allComments = allComments {
            if allComments.keys.contains(instrument){
                return allComments[instrument]!.count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mixedTrackCell", for: indexPath) as! AudioCommentCell
        let instrument = Instrument.cases[indexPath.section]
        if let allComments = allComments {
            if allComments.keys.contains(instrument){
                cell.comment = allComments[instrument]![indexPath.item]
            }
        }
        cell.tag = indexPath.item
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

}
