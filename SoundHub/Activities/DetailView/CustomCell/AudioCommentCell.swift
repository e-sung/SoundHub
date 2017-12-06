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
        delegate?.didSwitchToggled(to: sender.isOn, by: self.tag, of: commentInfo.instrument)
    }
    
    var delegate:AudioCommentCellDelegate?

    var commentInfo:Comment{
        get{
            return _commentInfo
        }
        set(newVal){
           _commentInfo = newVal
            InstrumentLB.text = newVal.instrument
            nickNameLB.text = newVal.author
        }
    }
    private var _commentInfo:Comment!
}

protocol AudioCommentCellDelegate {
    func didSwitchToggled(to state:Bool, by tag:Int, of instrument:String)
}
