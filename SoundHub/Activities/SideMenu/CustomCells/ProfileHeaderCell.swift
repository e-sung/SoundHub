//
//  ProfileHeaderCell.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 11. 29..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit

class ProfileHeaderCell: UITableViewCell, UIImagePickerControllerDelegate, UITextFieldDelegate{

    // MARK: Stored Properties
    var delegate:ProfileHeaderCellDelegate?
    static internal let defaultHeight:CGFloat = 330
    private var _isSettingPhase = false
    
    // MARK: IBOutlets
    @IBOutlet weak private var profileImageButton: UIButton!
    @IBOutlet weak private var headerImageButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak private var nickNameTF: UITextField!
    @IBOutlet weak var numFollowingLB: UILabel!
    @IBOutlet weak var numFollowerLB: UILabel!
    
    // MARK: IBActions
    @IBAction private func headerImageChangeHandler(_ sender: UIButton) {
        delegate?.shouldChangeImageOf(button: sender)
    }
    
    @IBAction private func profileImageChangeHandler(_ sender: UIButton) {
        delegate?.shouldChangeImageOf(button: sender)
    }
    
    // MARK: Computed Properties
    var isSettingPhase:Bool{
        get{
            return _isSettingPhase
        }
        set(newVal){
            _isSettingPhase = newVal
            profileImageButton.isUserInteractionEnabled = newVal
            headerImageButton.isUserInteractionEnabled = newVal
            nickNameTF.isEnabled = newVal
            nickNameTF.becomeFirstResponder()
        }
    }
    
    var nickName:String{
        get { return nickNameTF.text! }
        set(newVal){ nickNameTF.text = newVal }
    }

    func refresh(with userInfo:User?){
        if userInfo == nil {
            nickName = UserDefaults.standard.string(forKey: nickname)!
            settingButton.isHidden = false
        }else {
            nickName = userInfo!.nickname
            numFollowingLB.text = "\(userInfo!.num_followings ?? 0)"
            numFollowerLB.text = "\(userInfo!.num_followers ?? 0)"
            settingButton.isHidden = true
        }
    }
}

// MARK: Protocol Defenition
protocol ProfileHeaderCellDelegate {
    func shouldChangeImageOf(button:UIButton)
}
