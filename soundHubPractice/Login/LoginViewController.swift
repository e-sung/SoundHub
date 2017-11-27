//
//  LoginViewController.swift
//  LoginPractice
//
//  Created by 류성두 on 2017. 11. 24..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBAction func emailPrimaryActionHandler(_ sender: UITextField) {
        sender.resignFirstResponder()
        passwordTextField.becomeFirstResponder()
    }
    
    @IBAction func passwordPriamryActionHandler(_ sender: UITextField) {
        performSegue(withIdentifier: "showMain", sender: nil)
    }
    
    @IBAction func viewTouchHandler(_ sender: UITapGestureRecognizer) {
        if emailTextField.isFirstResponder || passwordTextField.isFirstResponder{
            print("touched when self.view is not first responder")
            emailTextField.resignFirstResponder()
            passwordTextField.resignFirstResponder()
            self.view.becomeFirstResponder()
        }else{
            print("touched when self.view is first responder")
            self.dismiss(animated: true, completion: nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

