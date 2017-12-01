//
//  ProfileViewController.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 11. 29..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController{

    // MARK: Stored Properties
    private var buttonToChange:UIButton?
    private var headerCell:ProfileHeaderCell!
    private let imagePicker = UIImagePickerController()
    
    // MARK: IBActions
    @IBAction private func confirmButtonHandler(_ sender: UIBarButtonItem) {
        confirmButton.title = ""
        confirmButton.isEnabled = false
        headerCell.isSettingPhase = false
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func goBackButtonHandler(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func changeProfileButtnHandler(_ sender: UIButton) {
        confirmButton.title = "확인"
        confirmButton.isEnabled = true
        headerCell.isSettingPhase = true
    }
    
    // MARK: IBOutlets
    @IBOutlet weak private var mainTV: UITableView!
    @IBOutlet weak private var confirmButton: UIBarButtonItem!
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        mainTV.delegate = self
        mainTV.dataSource = self
        confirmButton.title = ""
        confirmButton.isEnabled = false
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
    }
    
}

// MARK: ProfileHeaderCell Delegate
extension ProfileViewController:ProfileHeaderCellDelegate{
    func changeImageOf(button: UIButton) {
        buttonToChange = button
        present(photoSourceChooingAlert, animated: true, completion: nil)
    }
}

// MARK: ImagePickerDelegate
extension ProfileViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            buttonToChange?.setImage(pickedImage, for: .normal)
            buttonToChange?.imageView?.contentMode = .scaleAspectFill
        }
        dismiss(animated: true, completion: nil)
    }
}

// MARK: TableViewDelegate
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

// MARK: Computed Properties : AlertActions
extension ProfileViewController{
    private var defaultUIAlertActions:[UIAlertAction]{
        get{
            let withExistingPhoto = UIAlertAction(title: "원래 있던 사진으로", style: .default , handler: { (action) in
                self.imagePicker.sourceType = .photoLibrary
                self.present(self.imagePicker, animated: true, completion: nil)
            })
            
            let withNewPhoto = UIAlertAction(title: "새로 사진 찍어서", style: .default , handler: { (action) in
                self.imagePicker.sourceType = .camera
                self.present(self.imagePicker, animated: true, completion: nil)
            })
            
            let cancel = UIAlertAction(title: "취소", style: .cancel) { (action) in
                self.presentedViewController?.dismiss(animated: true, completion: nil)
            }
            return [withExistingPhoto, withNewPhoto, cancel]
        }
    }
    
    private var photoSourceChooingAlert:UIAlertController{
        get{
            let alert = UIAlertController(title: "사진 변경", message: "", preferredStyle: .actionSheet)
            let actions = defaultUIAlertActions
            for action in actions{
                alert.addAction(action)
            }
            return alert
        }
    }
}