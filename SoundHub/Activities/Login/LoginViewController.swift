//
//  LoginViewController.swift
//  LoginPractice
//
//  Created by 류성두 on 2017. 11. 24..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextViewDelegate {
    
    // MARK: Stored Properties
    var isKeyboardUp = false
    
    // MARK: IBOutlests
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: IBActions
    @IBAction func emailPrimaryActionHandler(_ sender: UITextField) {
        sender.resignFirstResponder()
        passwordTextField.becomeFirstResponder()
    }
    
    @IBAction func passwordPriamryActionHandler(_ sender: UITextField) {
//        performSegue(withIdentifier: "loginSuccessSegue", sender: nil)
    }
    
    @IBAction func loginButtonHandler(_ sender: UIButton) {
        guard let email = emailTextField.text else {
            alert(msg: "Email")
            return
        }
        guard let password = passwordTextField.text else {
            alert(msg: "password")
            return
        }
        NetworkController.main.login(with: email, and: password) {
            DispatchQueue.main.async(execute: {
                self.performSegue(withIdentifier: "loginSuccessSegue", sender: nil)
            })
        }
    }
    
    
    @IBAction func viewTouchHandler(_ sender: UITapGestureRecognizer) {
        if isKeyboardUp{
            self.view.endEditing(true)
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardDidShow, object: nil, queue: nil) { (noti) in
            self.isKeyboardUp = true
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardDidHide, object: nil, queue: nil) { (noti) in
            self.isKeyboardUp = false
        }
    }
    

}

