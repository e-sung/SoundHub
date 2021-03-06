//
//  SideMenuViewController.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 11. 29..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class SideMenuViewController: UIViewController {

    @IBOutlet weak private var nickNameButton: UIButton!
    @IBOutlet weak private var profileImageButton: UIButton!
    @IBOutlet weak private var logoutButton: UIButton!
    @IBAction private func logoutButtonHandler(_ sender: UIButton) {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        PlayBarController.main.stop()
        self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
    }

    @IBAction private func nickNameButtonHandler(_ sender: UIButton) { showProfile() }

    @IBAction private func profileImageButtonHandler(_ sender: UIButton) { showProfile() }

    @IBAction private func profileButtonHandler(_ sender: UIButton) { showProfile() }

    @IBAction private func homeButtonClickHandler(_ sender: UIButton) {
        performSegue(withIdentifier: "undwindToGeneralHome", sender: nil)
    }

    private func showProfile() {
        guard let userId = UserDefaults.standard.string(forKey: keyForUserId) else { return }
        guard let userID = Int(userId) else { return }
        NetworkController.main.fetchUser(id: userID) { (userInfo) in
            self.performSegue(withIdentifier: "sideMenuToProfileVC", sender: userInfo)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nextVC = segue.destination as? ProfileViewController {
            nextVC.userInfo = sender as? User
        }
        if let nextVC = segue.destination as? ChartViewController {
            nextVC.category = .general
            nextVC.shouldScrollToTop = true
        }
    }

    override func viewDidLoad() {
        guard let userId = UserDefaults.standard.string(forKey: keyForUserId) else {
            profileImageButton.setTitle("로그인 필요", for: .normal)
            logoutButton.setTitle("로그인", for: .normal)
            return
        }
        nickNameButton.setTitle(UserDefaults.standard.string(forKey: keyForNickName), for: .normal)
        if let socialProfileImageURL = DataCenter.main.socialProfileImageURL {
            profileImageButton.af_setBackgroundImage(for: .normal, url: socialProfileImageURL)
        }else{
            let imageURL = URL(string: "user_\(userId)/profile_img/profile_img_200.png", relativeTo: NetworkController.main.baseMediaURL)!
            profileImageButton.af_setImage(for: .normal, url: imageURL, placeholderImage: #imageLiteral(resourceName: "default-profile"), filter: nil, progress: nil, progressQueue: DispatchQueue.main, completion: nil)
        }
    }
}
