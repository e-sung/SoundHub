//
//  EntryViewController.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 12. 21..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit

class MainEnteryViewController: UIViewController {
    @IBAction func onProgressWithoutLoginButtonHandler(_ sender: UIButton) {
        performSegue(withIdentifier: "progressWithoutLogin", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
