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
    private var headerCell:ProfileHeaderCell?
    private let imagePicker = UIImagePickerController()
    var headerTitles = ["올린 포스트들","좋아한 포스트들"]
    var headerTitle = ""
    var userInfo:User?{
        didSet(oldVal){
            headerCell?.refresh(with: userInfo)
        }
    }
    
    // MARK: IBActions
    var doneButton:UIBarButtonItem!
    @objc func doneButtonHandler(){
        doneButton.title = ""
        doneButton.isEnabled = false
        UserDefaults.standard.set(headerCell!.nickName, forKey: nickname)
        NetworkController.main.patchUser(nickname: headerCell!.nickName, completion: {
            DataCenter.main = DataCenter()
            self.navigationController?.popViewController(animated: true)
        })
        headerCell!.isSettingPhase = false
    }

    @IBAction private func changeProfileButtnHandler(_ sender: UIButton) {
        doneButton.title = "확인"
        doneButton.isEnabled = true
        headerCell!.isSettingPhase = true
    }
    
    // MARK: IBOutlets
    @IBOutlet weak private var mainTV: UITableView!

    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        mainTV.delegate = self
        mainTV.dataSource = self
        
        doneButton = UIBarButtonItem(title: "", style: .done, target: self, action: #selector(doneButtonHandler))
        navigationItem.setRightBarButton(doneButton, animated: false)
        doneButton.isEnabled = false

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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            headerCell = tableView.dequeueReusableCell(withIdentifier: "profileHeaderCell", for: indexPath) as? ProfileHeaderCell
            headerCell!.delegate = self
            headerCell!.refresh(with: userInfo)
            return headerCell!
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "flowContainerCell", for: indexPath) as! FlowContainerCell
            cell.userInfo = userInfo
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 330
        }else{
            guard let userInfo = userInfo else { return 0 }
            guard let posts = userInfo.post_set else { return 0 }
            return PostListCell.defaultHeight*CGFloat(posts.count)
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 { return headerTitle }
        return nil
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 60
    }
}

extension ProfileViewController:FlowContainerCellDelegate{
    func shouldGoTo(post: Post) {
        NetworkController.main.fetchPost(id: post.id) { (post) in
            if post.title != PlayBarController.main.currentPostView?.post.title{
                let detailSB = UIStoryboard(name: "Detail", bundle: nil)
                let nextVC = detailSB.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
                nextVC.post = post
                DispatchQueue.main.async {
                    self.navigationController?.show(nextVC, sender: nil)
                }
                
            }else if let currentPostView = PlayBarController.main.currentPostView{
                DispatchQueue.main.async {
                    self.navigationController?.show(currentPostView, sender: nil)
                }
            }
        }
    }
    
    func didScrolledTo(page: Int) {
        headerTitle = headerTitles[page]
        mainTV.headerView(forSection: page)?.textLabel?.text = headerTitle
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
