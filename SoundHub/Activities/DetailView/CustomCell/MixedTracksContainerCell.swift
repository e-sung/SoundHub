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
//    var players:[AVPlayer]{
//        get{
//            var players:[AVPlayer] = []
//            for i in 0..<commentTV.numberOfSections{
//                for j in 0..<commentTV.numberOfRows(inSection: i){
//                    let cell = commentTV.cellForRow(at: IndexPath(item: j, section: i)) as! AudioCommentCell
//                    players.append(cell.player)
//                }
//            }
//            return players
//        }
//    }
//    var currentPlayRate:CGFloat{
//        get{
//            let player = (commentTV.cellForRow(at: IndexPath(item: 0, section: 0)) as! AudioCommentCell).player
//            player?.currentTime()
//            player?.currentItem?.timebase
//            return CGFloat(player?.currentTime())
//        }
//    }
    
    
    var aPlayer:AVPlayer!{
        didSet(oldVal){
            let cmt = CMTime(value: 1, timescale: 10)
            aPlayer.addPeriodicTimeObserver(forInterval: cmt, queue: DispatchQueue.main, using: { (cmt) in
                let progress = self.aPlayer.currentTime().seconds/self.aPlayer.currentItem!.duration.seconds
                print("a")
                if PlayBarController.main.progressBarBeingTouched == false{
                    PlayBarController.main.progressBar.setValue(Float(progress), animated: true)
                }
            })
        }
    }

    @IBOutlet weak var commentTV: UITableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commentTV.delegate = self
        commentTV.dataSource = self
    }

}

extension MixedTracksContainerCell{
    // MARK: Play and Pause Functions
    func setInteractionability(to bool:Bool){
        for i in 0..<commentTV.numberOfSections{
            for j in 0..<commentTV.numberOfRows(inSection: i){
                let cell = commentTV.cellForRow(at: IndexPath(item: j, section: i)) as! AudioCommentCell
                cell.toggleSwitch.isEnabled = bool
            }
        }
    }

    func playMusic(){
        for i in 0..<commentTV.numberOfSections{
            for j in 0..<commentTV.numberOfRows(inSection: i){
                let cell = commentTV.cellForRow(at: IndexPath(item: j, section: i)) as! AudioCommentCell
                cell.player.play()
            }
        }
    }

    func pauseMusic(){
        for i in 0..<commentTV.numberOfSections{
            for j in 0..<commentTV.numberOfRows(inSection: i){
                let cell = commentTV.cellForRow(at: IndexPath(item: j, section: i)) as! AudioCommentCell
                cell.player.pause()
            }
        }
    }
    
    func stopMusic(){
        for i in 0..<commentTV.numberOfSections{
            for j in 0..<commentTV.numberOfRows(inSection: i){
                let cell = commentTV.cellForRow(at: IndexPath(item: j, section: i)) as! AudioCommentCell
                cell.player.stop()
            }
        }
    }
    
    func seek(to proportion:Float){
        for i in 0..<commentTV.numberOfSections{
            for j in 0..<commentTV.numberOfRows(inSection: i){
                let cell = commentTV.cellForRow(at: IndexPath(item: j, section: i)) as! AudioCommentCell
                cell.player.seek(to:proportion)
            }
        }
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
        if indexPath == IndexPath(item: 0, section: 0) { aPlayer = cell.player }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

}
