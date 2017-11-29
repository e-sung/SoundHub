//
//  ProfileHeaderCell.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 11. 29..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit

class ProfileHeaderCell: UITableViewCell, UIImagePickerControllerDelegate {

    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var headerImageButton: UIButton!
    @IBOutlet weak var nickNameTF: UITextField!
    
    @IBAction func headerImageChangeHandler(_ sender: UIButton) {
        delegate?.changeImageOf(button: sender)
    }
    
    @IBAction func profileImageChangeHandler(_ sender: UIButton) {
        delegate?.changeImageOf(button: sender)
    }
    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        print(info)
//        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
//            headerImageButton.imageView?.image = pickedImage
//        }
//    }
    
    let imagePicker = UIImagePickerController()
    var isSettingPhase:Bool{
        get{
            return _isSettingPhase
        }
        set(newVal){
            profileImageButton.isUserInteractionEnabled = newVal
            headerImageButton.isUserInteractionEnabled = newVal
            nickNameTF.isEnabled = newVal
            _isSettingPhase = newVal
            nickNameTF.becomeFirstResponder()
        }
    }
    var delegate:ProfileHeaderCellDelegate?
    private var _isSettingPhase = false

    override func awakeFromNib() {
        super.awakeFromNib()
//        imagePicker.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
//        imagePicker.allowsEditing = false
//        imagePicker.sourceType = .photoLibrary
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

protocol ProfileHeaderCellDelegate {
    func changeImageOf(button:UIButton)
}
