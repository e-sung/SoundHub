//
//  ProfileViewController.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 11. 29..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, ProfileHeaderCellDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate  {
    func changeImageOf(button: UIButton) {
        buttonToChange = button
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            buttonToChange?.setImage(pickedImage, for: .normal)
            buttonToChange?.imageView?.contentMode = .scaleAspectFill
        }
        dismiss(animated: true, completion: nil)
    }
    
    var buttonToChange:UIButton?
    var headerCell:ProfileHeaderCell!
    let imagePicker = UIImagePickerController()
    @IBOutlet weak var confirmButton: UIBarButtonItem!
    @IBAction func confirmButtonHandler(_ sender: UIBarButtonItem) {
        confirmButton.title = ""
        confirmButton.isEnabled = false
        headerCell.isSettingPhase = false
    }
    
    @IBAction func goBackButtonHandler(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var mainTV: UITableView!
    
    @IBAction func changeProfileButtnHandler(_ sender: UIButton) {
        confirmButton.title = "확인"
        confirmButton.isEnabled = true
        headerCell.isSettingPhase = true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainTV.delegate = self
        mainTV.dataSource = self
        confirmButton.title = ""
        confirmButton.isEnabled = false
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
    }

}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.headerCell = tableView.dequeueReusableCell(withIdentifier: "profileHeaderCell", for: indexPath) as! ProfileHeaderCell
        self.headerCell.delegate = self
        return self.headerCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 330
    }
}
