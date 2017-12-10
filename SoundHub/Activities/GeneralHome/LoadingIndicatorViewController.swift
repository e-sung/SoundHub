//
//  LoadingIndicatorViewController.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 12. 9..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class LoadingIndicatorViewController: UIViewController {

    var previousVC:ChartViewController!
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    
    override func viewWillAppear(_ animated: Bool) {
        activityIndicator.startAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NetworkController.main.fetchHomePage(of: previousVC.category, with: previousVC.option) {
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.previousVC.refreshData()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
