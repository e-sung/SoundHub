//
//  SignUpViewController.swift
//  soundHubPractice
//
//  Created by 류성두 on 2017. 11. 27..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit
import LPSnackbar

/// - ToDo : Input 값의 Validity확인
class SignUpViewController: UIViewController, UITextFieldDelegate {

    // MARK: Stored Properties
    var isKeyboardUp = false
    
    // MARK: IBOutlets
    @IBOutlet weak var errorMsgLB: UILabel!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var nickNameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var passwordConfirmTF: UITextField!
    @IBOutlet var textFields: [UITextField]!
    
    // MARK: IBActions
    
    @IBAction func emailButtonHandler(_ sender: UIButton) {
        if isReadyToSignUp(){
            performSegue(withIdentifier: "signUpToProfileSetUp", sender: self)
        }
    }
    
    @IBAction func emailConfirmHandler(_ sender: UITextField) {
        sender.resignFirstResponder()
        nickNameTF.becomeFirstResponder()
        checkEmailValidity()
    }

    @IBAction func nickNameConfirmHandler(_ sender: UITextField) {
        sender.resignFirstResponder()
        passwordTF.becomeFirstResponder()
    }
    @IBAction func passwordConfirmHandler(_ sender: UITextField) {
        sender.resignFirstResponder()
        passwordConfirmTF.becomeFirstResponder()
        checkPasswordValidity()
    }
    @IBAction func passwordFinalConfirmHandler(_ sender: UITextField) {
        if isReadyToSignUp(){
            performSegue(withIdentifier: "signUpToProfileSetUp", sender: self)
        }
    }
    
    @IBAction func onTouchHandler(_ sender: UITapGestureRecognizer) {
        if isKeyboardUp { self.view.endEditing(true) }
        else{ self.dismiss(animated: true, completion: nil) }
    }
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        for tf in textFields{ tf.delegate = self }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardDidShow, object: nil, queue: nil) { (noti) in
            self.isKeyboardUp = true
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardDidHide, object: nil, queue: nil) { (noti) in
            self.isKeyboardUp = false
        }
    }
}

// MARK: Segue Config
extension SignUpViewController{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextVC = segue.destination as! ProfileSetUpViewController
        nextVC.email = emailTF.text!
        nextVC.nickName = nickNameTF.text!
        nextVC.password = passwordTF.text!
        nextVC.passwordConfirm = passwordConfirmTF.text!
    }
}

extension SignUpViewController{
    
    func isReadyToSignUp()->Bool{
        checkEmailValidity()
        if errorMsgLB.text?.isEmpty == false { return false }
        checkPasswordValidity()
        if errorMsgLB.text?.isEmpty == false { return false }
        checkPasswordConfirmValidity()
        if errorMsgLB.text?.isEmpty == false { return false }
        return true
    }
    
    func checkEmailValidity(){
        guard let email = emailTF.text else {
            errorMsgLB.text = "Fill in Email Address!"
            nickNameTF.resignFirstResponder()
            emailTF.becomeFirstResponder()
            return
        }
        if email.isValidEmail == false {
            errorMsgLB.text = "Email Syntax is Invalid"
            nickNameTF.resignFirstResponder()
            emailTF.becomeFirstResponder()
        }
        else {
            errorMsgLB.text = ""
            emailTF.resignFirstResponder()
            nickNameTF.becomeFirstResponder()
        }
    }
    
    func checkPasswordValidity(){
        guard let password = passwordTF.text else {
            errorMsgLB.text = "Fill in Password!"
            passwordConfirmTF.resignFirstResponder()
            passwordTF.becomeFirstResponder()
            return
        }
        if password.isValidPassword == false {
            errorMsgLB.text = "Minimum Password Length : 10 "
            passwordConfirmTF.resignFirstResponder()
            passwordTF.becomeFirstResponder()
        }
        else {
            errorMsgLB.text = ""
            passwordTF.resignFirstResponder()
            passwordConfirmTF.becomeFirstResponder()
        }
    }
    
    func checkPasswordConfirmValidity(){
        guard let password = passwordConfirmTF.text else {
            errorMsgLB.text = "Fill in Password Confirm Field"
            passwordConfirmTF.becomeFirstResponder()
            return
        }
        if password.isValidPassword == false {
            errorMsgLB.text = "Minimum password Length : 10 "
            passwordConfirmTF.becomeFirstResponder()
        }
        else if password != passwordTF.text {
            errorMsgLB.text = "Password doesn't match!"
            passwordConfirmTF.becomeFirstResponder()
        }
        else { errorMsgLB.text = "" }
    }
}
