//
//  AudioCommentCell.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 11. 30..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit
import AlamofireImage
import AVFoundation

class AudioCommentCell: UITableViewCell {
    
    var player:AVPlayer?
    
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak private var InstrumentLB: UILabel!
    @IBOutlet weak private var nickNameLB: UILabel!
    @IBOutlet weak private var toggleSwitch: UISwitch!
    
    @IBAction func onProfileButtonClicked(_ sender: UIButton) {
        delegate?.shouldShowProfileOf(user: comment.author)
    }
    @IBAction private func switchToggleHandler(_ sender: UISwitch) {
        if sender.isOn {player?.isMuted = false}
        else { player?.isMuted = true }
        delegate?.didSwitchToggled()
    }
    func toggleSwitch(to value:Bool){
        toggleSwitch.isOn = value
        player?.isMuted = !value
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
            nickNameLB.text = newVal.author?.nickname
            guard let audioURL = newVal.commentTrackURL else { return }
            player = AVPlayer(url:audioURL)
            player?.isMuted = true
//            NetworkController.main.downloadAudio(from: audioURL) { (localURL) in
//                self.player = AVPlayer(url: localURL)
//                self.player?.isMuted = true
//            }
            if let profileImageURL = newVal.author?.profileImageURL{
                profileImageButton.af_setImage(for: .normal, url: profileImageURL)
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

extension AudioCommentCell:Playable{
    func play(){
        player?.play()
    }
    func pause(){
        player?.pause()
    }
    func stop(){
        player?.stop()
    }
    func seek(to proportion:Float){
        player?.seek(to: proportion)
    }
    func setVolume(to value: Float) {
        player?.volume = value
    }
    func setMute(to value: Bool) {
        player?.isMuted = value
    }
}

protocol AudioCommentCellDelegate {
    func didSwitchToggled()
    func shouldShowProfileOf(user:User?)
}
