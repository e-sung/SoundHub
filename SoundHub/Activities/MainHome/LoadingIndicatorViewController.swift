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
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    override func viewWillAppear(_ animated: Bool) {
        activityIndicator.type = .ballScaleRipple
        activityIndicator.startAnimating()
    }
}
