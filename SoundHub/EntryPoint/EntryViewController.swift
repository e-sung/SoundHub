//
//  EntryViewController.swift
//  soundHubPractice
//
//  Created by 류성두 on 25/11/2017.
//  Copyright © 2017 류성두. All rights reserved.
//

import UIKit

class EntryViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.object(forKey: "token") != nil {
            self.performSegue(withIdentifier: "showGeneral", sender: nil)
        }else{
            performSegue(withIdentifier: "showLogin", sender: nil)
        }
    }
}
