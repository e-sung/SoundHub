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
        if UserDefaults.standard.object(forKey: keyForToken) != nil {
            self.performSegue(withIdentifier: "showMainTabBar", sender: nil)
        }else{
            performSegue(withIdentifier: "showLogin", sender: nil)
        }
    }
}
