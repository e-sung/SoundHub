//
//  EntryViewController.swift
//  soundHubPractice
//
//  Created by 류성두 on 25/11/2017.
//  Copyright © 2017 류성두. All rights reserved.
//

import UIKit

class EntryViewController: UIViewController {
    
    var isUserLoggedIn:Bool{
        get{
            return false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if isUserLoggedIn{
            //Show Main RankingPage
        }else{
            performSegue(withIdentifier: "showLogin", sender: nil)
        }
    }

}
