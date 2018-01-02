//
//  ModeToggleCell.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 12. 6..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit

class ModeToggleCell: UITableViewCell {
    var containerToToggle: CommentContainerCell?
    @IBOutlet weak var modeStateLB: UILabel!
    @IBAction func switchToggleHandler(_ sender: UISwitch) {
        delegate?.didModeToggled(to: sender.isOn, by: containerToToggle)
    }
    weak var delegate: ModeToggleCellDelegate?
}
protocol ModeToggleCellDelegate: class {
    func didModeToggled(to mode: Bool, by toggler: CommentContainerCell?)
}
