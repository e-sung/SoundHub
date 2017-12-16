//
//  SideMenuViewController.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 11. 29..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit

class SideMenuViewController: UIViewController {
    
    @IBOutlet weak var nickNameButton:UIButton!
    @IBOutlet weak var profileImageButton:UIButton!
    
    @IBAction func logoutButtonHandler(_ sender: UIButton) {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func nickNameButtonHandler(_ sender: UIButton) { showProfile() }
    
    @IBAction func profileImageButtonHandler(_ sender: UIButton) { showProfile() }
    
    @IBAction func profileButtonHandler(_ sender: UIButton) { showProfile() }
    
    func showProfile(){
        guard let userId = UserDefaults.standard.string(forKey: id) else { return }
        guard let userID = Int(userId) else { return }
        NetworkController.main.fetchUser(id: userID) { (userInfo) in
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "sideMenuToProfileVC", sender: userInfo)
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nextVC = segue.destination as? ProfileViewController {
            nextVC.userInfo = sender as? User
        }
    }

    override func viewDidLoad(){
        nickNameButton.setTitle(UserDefaults.standard.string(forKey: nickname) , for: .normal)
    }
}
