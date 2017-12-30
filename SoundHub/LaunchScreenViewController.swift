//
//  LaunchScreenViewController.swift
//  SoundHub
//
//  Created by esung on 2017. 12. 30..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class LaunchScreenViewController: UIViewController {

    @IBOutlet weak var loadingIndicator: NVActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingIndicator.color = .white
        loadingIndicator.type = .ballScale
        loadingIndicator.startAnimating()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
