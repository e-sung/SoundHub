//
//  AudioCommentCell.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 11. 30..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit
import AVFoundation

class AudioCommentCell: UITableViewCell {
    
    var player:AVPlayer?
    
    @IBOutlet weak private var profileImageView: UIImageView!
    @IBOutlet weak private var InstrumentLB: UILabel!
    @IBOutlet weak private var nickNameLB: UILabel!
    @IBOutlet weak private var toggleSwitch: UISwitch!
    
    @IBAction private func switchToggleHandler(_ sender: UISwitch) {
        if sender.isOn { player?.volume = 1.0 }
        else { player?.volume = 0.0 }
    }
    func toggleSwitch(to value:Bool){
        toggleSwitch.isOn = value
        player?.volume = toggleSwitch.isOn ? 1.0 : 0.0
    }
    var delegate:AudioCommentCellDelegate?
    var isActive:Bool{
        get{
            return toggleSwitch.isOn
        }
    }
    var isInterActive:Bool{
        get{
            return toggleSwitch.isEnabled
        }set(newVal){
            toggleSwitch.isEnabled = newVal
        }
    }

    var comment:Comment{
        get{
            return _commentInfo
        }
        set(newVal){
           _commentInfo = newVal
            InstrumentLB.text = newVal.instrument
            nickNameLB.text = newVal.author
            let remoteURL = URL(string: newVal.comment_track.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)!, relativeTo: NetworkController.main.baseMediaURL)!
            NetworkController.main.downloadAudio(from: remoteURL) { (localURL) in
                self.player = AVPlayer(url: localURL)
                self.player?.volume = 0
            }
        }
    }
    private var _commentInfo:Comment!
    override func awakeFromNib() {
        let bgColorView = UIView(frame: contentView.frame)
        bgColorView.backgroundColor = UIColor(red: 0, green: 1.0, blue: 0, alpha: 0.3)
        self.selectedBackgroundView = bgColorView
    }
}

protocol AudioCommentCellDelegate {
    func didSwitchToggled(to state:Bool, by tag:Int, of instrument:String)
}
