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
    
    @IBOutlet weak var nickNameButton:UIButton!
    @IBOutlet weak var profileImageButton:UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBAction func logoutButtonHandler(_ sender: UIButton) {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nickNameButtonHandler(_ sender: UIButton) { showProfile() }
    
    @IBAction func profileImageButtonHandler(_ sender: UIButton) { showProfile() }
    
    @IBAction func profileButtonHandler(_ sender: UIButton) { showProfile() }
    
    @IBAction func homeButtonClickHandler(_ sender: UIButton) {
        performSegue(withIdentifier: "undwindToGeneralHome", sender: nil)
    }
    
    func showProfile(){
        guard let userId = UserDefaults.standard.string(forKey: id) else { return }
        guard let userID = Int(userId) else { return }
        NetworkController.main.fetchUser(id: userID) { (userInfo) in
            self.performSegue(withIdentifier: "sideMenuToProfileVC", sender: userInfo)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nextVC = segue.destination as? ProfileViewController {
            nextVC.userInfo = sender as? User
        }
        if let nextVC = segue.destination as? ChartViewController{
            nextVC.category = .general
            nextVC.shouldScrollToTop = true
        }
    }

    override func viewDidLoad(){
        guard let userId = UserDefaults.standard.string(forKey: id) else {
            profileImageButton.setTitle("로그인 필요", for: .normal)
            logoutButton.setTitle("로그인", for: .normal)
            return
        }
        nickNameButton.setTitle(UserDefaults.standard.string(forKey: nickname) , for: .normal)
        let imageURL = URL(string: "user_\(userId)/profile_img/profile_img_200.png", relativeTo: NetworkController.main.baseMediaURL)!
        profileImageButton.af_setBackgroundImage(for: .normal, url: imageURL)
    }
}
