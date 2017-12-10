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
