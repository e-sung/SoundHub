//
//  ProfileViewController.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 11. 29..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

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
    private var buttonToChange: UIButton?
    private var changedProfileImage: UIImage?
    private var changedHeaderImage: UIImage?

    /**
     User객체의 주요 정보가 표시되는 셀

     * 주요 정보
         1. 프로필 이미지
         2. 헤더 이미지
         3. 닉네임
         4. 팔로잉/팔로워
    */
    private var headerCell: ProfileHeaderCell?
    private var flowCell: FlowContainerCell?
    /**
     사진첩, 혹은 카메라에 접근할 수 있는 객체
     - ToDo: 사진첩/카메라에 접근권한을 갖지 못했을 때에 대한 처리를 해야 함
    */
    private let imagePicker = UIImagePickerController()
    private var tableViewHeaderTitles = ["올린 포스트들", "좋아한 포스트들"]
    /**
     이 VC를 통해 표시되어야 할 User 객체. 유일한 internal 객체이다.
    */
    var userInfo: User? { didSet(oldVal) { headerCell?.refresh(with: userInfo) } }
    /// 유저가 유저정보를 수정하는동안에만 보이는 UIBarButtonItem
    private var doneButton: UIBarButtonItem!

    // MARK: Objc Functions
    @objc func showsidemenu() { self.showSideMenu() }
    /**
     유저가 수정한 유저정보를 UserDefault에 저장하고, 같은 정보를 서버에 보냄
    */
    @objc private func doneButtonHandler() {
        _ = navigationItem.rightBarButtonItems?.popLast()

        UserDefaults.standard.set(headerCell!.nickName, forKey: keyForNickName)

        /// 변경내용을 서버에 반영
        self.showLoadingIndicator()
        NetworkController.main.patch(profileImage: changedProfileImage, headerImage: changedHeaderImage)
        guard let headerCell = headerCell else { return }
        NetworkController.main.patchUser(nickname: headerCell.nickName, instrument: headerCell.instrument) { (requestSucceded) in
            NotificationCenter.default.post(name: NSNotification.Name.init("shouldReloadContents"), object: nil)
            self.presentedViewController?.dismiss(animated: true, completion: nil)
        }
        headerCell.isSettingPhase = false
    }

    // MARK: IBActions
    /// 톱니바퀴 버튼을 눌렀을 때 해야 할 일
    @IBAction private func changeProfileButtnHandler(_ sender: UIButton) {
        doneButton = UIBarButtonItem(title: "확인", style: .done, target: self, action: #selector(doneButtonHandler))
        if navigationItem.rightBarButtonItems?.count == 1 {
            navigationItem.rightBarButtonItems?.append(doneButton)
        }
        headerCell!.isSettingPhase = true
    }

    @IBAction func swipeDidHappend(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .up {
            mainTV.scrollToRow(at: IndexPath(item: 0, section: 1), at: .top, animated: true)
            flowCell?.isScrollEnabled = true
        }
        self.view.endEditing(true)
    }

    @IBAction func tapDidHappend(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
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
    @IBOutlet weak var mainTV: UITableView!
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!

    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpDelegatesAndDataSources()
        fillInUI(with: userInfo)
        setUpSideMenuButton()
        NotificationCenter.default.addObserver(forName: NSNotification.Name("shouldReloadContents"), object: nil, queue: nil) { (noti) in
            self.fillInUI(with: self.userInfo)
        }
    }
}

extension ProfileViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let y = touch.location(in: view).y
        guard let headerCell = headerCell else { return true}
        return y < headerCell.frame.maxX
    }
}

// MARK: ProfileHeaderCell Delegate
extension ProfileViewController: ProfileHeaderCellDelegate {
    func shouldChangeImageOf(button: UIButton) {
        buttonToChange = button
        present(photoSourceChooingAlert, animated: true, completion: nil)
    }
}

// MARK: ImagePickerDelegate
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            buttonToChange?.setImage(pickedImage, for: .normal)
            buttonToChange?.imageView?.contentMode = .scaleAspectFill
            if buttonToChange?.tag == 0 { changedProfileImage = pickedImage }
            else { changedHeaderImage = pickedImage }
        }
        dismiss(animated: true, completion: nil)
    }
}

// MARK: TableViewDelegate
extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {

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
            cell.parent = self
            flowCell = cell
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return ProfileHeaderCell.defaultHeight
        }else {
            return self.view.frame.height
        }
    }

}
// MARK: FlowContainerCellDelegate
extension ProfileViewController: FlowContainerCellDelegate {
    func shouldShowProfile(of user: User?) {
        if user?.id == userInfo?.id { return }
        let profileVC = UIStoryboard(name: "SideMenu", bundle: nil).instantiateViewController(withIdentifier: "profileViewController") as! ProfileViewController
        profileVC.userInfo = user
        navigationController?.pushViewController(profileVC, animated: true)
    }

    func shouldGoTo(post: Post) {
        DetailViewController.goToDetailPage(of: post, from: self)
    }

    var isScrollEnabled: Bool {
        get { return mainTV.isScrollEnabled
        }set(newVal) { mainTV.isScrollEnabled = newVal }
    }
}

// MARK: Computed Properties : AlertActions
extension ProfileViewController {
    private var defaultUIAlertActions: [UIAlertAction] {
        let withExistingPhoto = UIAlertAction(title: "원래 있던 사진으로", style: .default, handler: { (action) in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        })

        let withNewPhoto = UIAlertAction(title: "새로 사진 찍어서", style: .default, handler: { (action) in
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        })

        let cancel = UIAlertAction(title: "취소", style: .cancel) { (action) in
            self.presentedViewController?.dismiss(animated: true, completion: nil)
        }
        return [withExistingPhoto, withNewPhoto, cancel]
    }

    private var photoSourceChooingAlert: UIAlertController {
        let alert = UIAlertController(title: "사진 변경", message: "", preferredStyle: .actionSheet)
        let actions = defaultUIAlertActions
        for action in actions {
            alert.addAction(action)
        }
        return alert
    }
}

// MARK: Helper Functions
extension ProfileViewController {

    private func setUpSideMenuButton() {
        let sideMenuButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "Hamburger_icon"), style: .plain, target: self, action: #selector(showsidemenu))
        self.navigationItem.rightBarButtonItem = sideMenuButton
    }

    private func setUpDelegatesAndDataSources() {
        mainTV.delegate = self
        mainTV.dataSource = self
        tapGestureRecognizer.delegate = self
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
    }

    private func fillInUI(with userInfo: User?) {
        if userInfo?.post_set == nil {
            guard let userId = userInfo?.id else { return }
            NetworkController.main.fetchUser(id: userId, completion: { (userResult) in
                guard let userResult = userResult else { return }
                self.userInfo = userResult
                let ids = IndexSet.init(integersIn: 1...1)
                self.mainTV.reloadSections(ids, with: .automatic)
            })
        }
    }
}
