//
//  ProfileHeaderCell.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 11. 29..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class ProfileHeaderCell: UITableViewCell, UIImagePickerControllerDelegate, UITextFieldDelegate {

    // MARK: Stored Properties
    weak var delegate:ProfileHeaderCellDelegate?
    static internal let defaultHeight:CGFloat = 330
    private var _isSettingPhase = false

    // MARK: IBOutlets
    @IBOutlet weak private var profileImageButton: UIButton!
    @IBOutlet weak private var headerImageButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak private var nickNameTF: UITextField!
    @IBOutlet weak var numFollowingLB: UILabel!
    @IBOutlet weak var numFollowerLB: UILabel!
    @IBOutlet weak var instrumentTF: UITextField!

    // MARK: IBActions
    @IBAction private func headerImageChangeHandler(_ sender: UIButton) {
        delegate?.shouldChangeImageOf(button: sender)
    }

    @IBAction private func profileImageChangeHandler(_ sender: UIButton) {
        delegate?.shouldChangeImageOf(button: sender)
    }

    // MARK: Computed Properties
    var isSettingPhase:Bool {
        get {
            return _isSettingPhase
        }
        set(newVal) {
            _isSettingPhase = newVal
            profileImageButton.isUserInteractionEnabled = newVal
            headerImageButton.isUserInteractionEnabled = newVal
            instrumentTF.isEnabled = newVal
            nickNameTF.isEnabled = newVal
            nickNameTF.becomeFirstResponder()
        }
    }

    var nickName:String {
        get { return nickNameTF.text! }
        set(newVal) { nickNameTF.text = newVal }
    }
    var instrument:String {
        get { return instrumentTF.text! }
        set(newVal) { instrumentTF.text = newVal }
    }

    func refresh(with userInfo:User?) {
        guard let userInfo = userInfo else { return }
        if let profileImageURL = userInfo.profileImageURL {
            profileImageButton.af_setImage(for: .normal, url: profileImageURL, placeholderImage: #imageLiteral(resourceName: "default-profile"), filter: nil, progress: nil, progressQueue: DispatchQueue.main, completion: nil)
        }
        if let headerImageURL = userInfo.headerImageURL {
            headerImageButton.af_setBackgroundImage(for: .normal, url: headerImageURL)
        }
        guard let userName = userInfo.nickname else { return }
        nickName = userName
        numFollowingLB.text = "\(userInfo.num_followings ?? 0)"
        numFollowerLB.text = "\(userInfo.num_followers ?? 0)"
        instrumentTF.text = userInfo.instrument
        settingButton.isHidden = true
        guard let userId = UserDefaults.standard.string(forKey: keyForUserId) else { return }
        guard let uid = Int(userId) else { return }
        if userInfo.id == uid {
            settingButton.isHidden = false
        }
    }
}

// MARK: Protocol Defenition
protocol ProfileHeaderCellDelegate: class {
    func shouldChangeImageOf(button:UIButton)
}
