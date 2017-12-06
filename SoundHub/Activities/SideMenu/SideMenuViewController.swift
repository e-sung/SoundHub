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
    
    override func viewDidLoad(){
        nickNameButton.setTitle(UserDefaults.standard.string(forKey: nickname) , for: .normal)
    }
}
