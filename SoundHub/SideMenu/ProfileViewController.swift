//
//  ProfileViewController.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 11. 29..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    var headerCell:ProfileHeaderCell!
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
        // Do any additional setup after loading the view.
    }

}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.headerCell = tableView.dequeueReusableCell(withIdentifier: "profileHeaderCell", for: indexPath) as! ProfileHeaderCell
        return self.headerCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 330
    }
}
