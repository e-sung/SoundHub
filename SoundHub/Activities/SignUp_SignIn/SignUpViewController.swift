//
//  SignUpViewController.swift
//  soundHubPractice
//
//  Created by 류성두 on 2017. 11. 27..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit
import LPSnackbar
import GoogleSignIn

/// - ToDo : Input 값의 Validity확인
class SignUpViewController: UIViewController, UITextFieldDelegate, GIDSignInUIDelegate {

    // MARK: Stored Properties
    var isKeyboardUp = false
    var token:String?
    var socialNickname:String?
    
    // MARK: IBOutlets
    @IBOutlet weak var errorMsgLB: UILabel!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var nickNameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var passwordConfirmTF: UITextField!
    @IBOutlet var textFields: [UITextField]!
    @IBOutlet weak var emailSignUpStackView: UIStackView!
    @IBOutlet weak var googleSignInButton: UIButton!
    
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    
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
    
    @IBAction func googleSignUpHandler(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signIn()
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
        GIDSignIn.sharedInstance().uiDelegate = self
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: "ToggleAuthUINotification"), object: nil, queue: nil) { (noti) in
            if let dic = noti.userInfo as NSDictionary?{
                self.token = dic["token"] as? String
                self.socialNickname = dic["nickname"] as? String
                self.performSegue(withIdentifier: "signUpToProfileSetUp", sender: self)
            }
        }
        tapGestureRecognizer.delegate = self
    }
}

extension SignUpViewController:UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let y = touch.location(in: view).y
        return y < emailSignUpStackView.frame.minY || y > googleSignInButton.frame.maxY
    }
}

// MARK: Segue Config
extension SignUpViewController{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextVC = segue.destination as! ProfileSetUpViewController
        if let token = self.token{
            nextVC.token = token
            nextVC.nickName = socialNickname!
        }else{
            nextVC.email = emailTF.text!
            nextVC.nickName = nickNameTF.text!
            nextVC.password = passwordTF.text!
            nextVC.passwordConfirm = passwordConfirmTF.text!
        }
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
