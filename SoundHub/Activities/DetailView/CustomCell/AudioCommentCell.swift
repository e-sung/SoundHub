//
//  AudioCommentCell.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 11. 30..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit

class AudioCommentCell: UITableViewCell {
    
    @IBOutlet weak private var profileImageView: UIImageView!
    @IBOutlet weak private var InstrumentLB: UILabel!
    @IBOutlet weak private var nickNameLB: UILabel!
    
    @IBAction private func switchToggleHandler(_ sender: UISwitch) {
        delegate?.didSwitchToggled(state: sender.isOn, by: self.tag)
    }
    
    var delegate:AudioCommentCellDelegate?

    var commentInfo:Comment{
        get{
            return _commentInfo
        }
        set(newVal){
           _commentInfo = newVal
            InstrumentLB.text = newVal.instrument
//            nickNameLB.text = newVal.comment_track
        }
    }
    private var _commentInfo:Comment!
}

protocol AudioCommentCellDelegate {
    func didSwitchToggled(state:Bool, by tag:Int)
}
