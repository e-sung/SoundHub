//
//  SideMenuViewController.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 11. 29..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit

class SideMenuViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nicknameLB: UILabel!
    
    
    @IBAction func logoutButtonHandler(_ sender: UIButton) {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad(){
        nicknameLB.text = UserDefaults.standard.string(forKey: "nickName")
    }
}
