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
    /**
     이미지피커에서 유저가 고른 이미지가 최종적으로 반영되어야 하는 버튼
     - Example:
        1. 유저가 프로필 이미지를 클릭
        2. 이미지 피커 등장
        3. 유저가 이미지를 픽함
        4. 픽된 이미지가 buttonToChange의 backgroundImage로 지정됨
   
     UIImagePickerControllerDelegate Method 참고
    */
    private var buttonToChange:UIButton?
    private var changedProfileImage:UIImage?
    private var changedHeaderImage:UIImage?
    
    /**
     User객체의 주요 정보가 표시되는 셀
     
     * 주요 정보
         1. 프로필 이미지
         2. 헤더 이미지
         3. 닉네임
         4. 팔로잉/팔로워
    */
    private var headerCell:ProfileHeaderCell?
    /**
     사진첩, 혹은 카메라에 접근할 수 있는 객체
     - ToDo: 사진첩/카메라에 접근권한을 갖지 못했을 때에 대한 처리를 해야 함
    */
    private let imagePicker = UIImagePickerController()
    private var tableViewHeaderTitles = ["올린 포스트들","좋아한 포스트들"]
    /**
     이 VC를 통해 표시되어야 할 User 객체. 유일한 internal 객체이다.
    */
    var userInfo:User?{ didSet(oldVal) { headerCell?.refresh(with: userInfo) } }
    /// 유저가 유저정보를 수정하는동안에만 보이는 UIBarButtonItem
    private var doneButton:UIBarButtonItem!
    
    // MARK: Objc Functions
    /**
     유저가 수정한 유저정보를 UserDefault에 저장하고, 같은 정보를 서버에 보냄
     - ToDo : 프로필 이미지, 헤더이미지도 변경해야 함
    */
    @objc private func doneButtonHandler(){
        /// 수정이 끝났다는 것을 보여주기 위하여, doneButton을 숨김
        doneButton.title = ""
        doneButton.isEnabled = false
        
        /// 수정된 내용을 UserDefaults에 저장
        /// - ToDo
        /// 프로필 이미지, 헤더이미지 저장 필요
        UserDefaults.standard.set(headerCell!.nickName, forKey: nickname)
        NetworkController.main.patchImage(with: changedProfileImage) { (success) in
            print("==============")
            print(success)
        }
//
        
        /// 변경내용을 서버에 반영
//        NetworkController.main.patchUser(nickname: headerCell!.nickName, profileImage: nil, headerImage: nil, completion: { requestSucceded in
//            if requestSucceded == true {
//                /// 네트워크 세션이 끝난 지금까지도 각종 UI에 변경되기 전 User데이터가 표시되고 있음.
//                /// 또 DataCenter.main 에도 아직 새 User객체가 반영되지 않았음.
//                /// 따라서
//                DataCenter.main = DataCenter() /// 1. DataCenter.main 초기화
//                self.navigationController?.popViewController(animated: true) /// 2. ChartVC로 복귀
//                /// 3. ChartVC에서는 DataCenter.main을 참조하려고 할 것이고, 그것이 비어있기 때문에
//                /// 4. 새 http 요청으로 DataCenter.main을 채워넣음.
//                /// 5. 그 과정에서 새롭게 변경된 User객체가 모든 UI에 반영됨
//            }else{
//                self.alert(msg: "요청이 실패했습니다. 어떻게 된걸까요?")
//            }
//        })
        headerCell!.isSettingPhase = false
    }
    
    // MARK: IBActions
    /// 톱니바퀴 버튼을 눌렀을 때 해야 할 일
    @IBAction private func changeProfileButtnHandler(_ sender: UIButton) {
        doneButton.title = "확인"
        doneButton.isEnabled = true
        headerCell!.isSettingPhase = true
    }
    
    // MARK: IBOutlets
    /**
     최상단의 TableView
     - mainTV
        - headerCell
        - FlowLayoutContainerCell
            - postedPostTableView
            - likedPostTableView
    */
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
    func shouldChangeImageOf(button: UIButton) {
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
            changedProfileImage = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
}

// MARK: TableViewDelegate
extension ProfileViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // headerCell & FlowContainerCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 { // headerCell 일 경우
            headerCell = tableView.dequeueReusableCell(withIdentifier: "profileHeaderCell", for: indexPath) as? ProfileHeaderCell
            headerCell!.delegate = self
            headerCell!.refresh(with: userInfo)
            return headerCell!
        }else { // flowContainer 일 경우
            let cell = tableView.dequeueReusableCell(withIdentifier: "flowContainerCell", for: indexPath) as! FlowContainerCell
            cell.userInfo = userInfo
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return ProfileHeaderCell.defaultHeight
        }else{
            guard let userInfo = userInfo else { return 0 }
            guard let posts = userInfo.post_set else { return 0 }
            return PostListCell.defaultHeight*CGFloat(posts.count)
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? nil : tableViewHeaderTitles[0]
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 60
    }
}

extension ProfileViewController:FlowContainerCellDelegate{
    func shouldGoTo(post: Post) {
        DetailViewController.goToDetailPage(of: post, from: self)
    }
    
    func didScrolledTo(page: Int) {
        mainTV.headerView(forSection: page)?.textLabel?.text = tableViewHeaderTitles[page]
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
