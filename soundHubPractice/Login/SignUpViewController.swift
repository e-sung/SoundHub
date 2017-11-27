//
//  SignUpViewController.swift
//  soundHubPractice
//
//  Created by 류성두 on 2017. 11. 27..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {

    var isKeyboardUp = false
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var nickNameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var passwordConfirmTF: UITextField!
    
    @IBAction func emailConfirmHandler(_ sender: UITextField) {
        sender.resignFirstResponder()
        nickNameTF.becomeFirstResponder()
    }
    @IBAction func nickNameConfirmHandler(_ sender: UITextField) {
        sender.resignFirstResponder()
        passwordTF.becomeFirstResponder()
    }
    @IBAction func passwordConfirmHandler(_ sender: UITextField) {
        sender.resignFirstResponder()
        passwordConfirmTF.becomeFirstResponder()
    }
    @IBAction func passwordFinalConfirmHandler(_ sender: UITextField) {
        print("asdf")
    }
    @IBAction func onTouchHandler(_ sender: UITapGestureRecognizer) {
        if isKeyboardUp {
            self.view.endEditing(true)
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
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
