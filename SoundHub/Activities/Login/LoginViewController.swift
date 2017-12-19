//
//  LoginViewController.swift
//  LoginPractice
//
//  Created by 류성두 on 2017. 11. 24..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit
import GoogleSignIn

class LoginViewController: UIViewController, UITextViewDelegate,GIDSignInUIDelegate {
    
    // MARK: Stored Properties
    var isKeyboardUp = false
    
    // MARK: IBOutlests
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: GIDSignInButton!
    
    // MARK: IBActions
    @IBAction func emailPrimaryActionHandler(_ sender: UITextField) {
        sender.resignFirstResponder()
        passwordTextField.becomeFirstResponder()
    }
    
    @IBAction func passwordPriamryActionHandler(_ sender: UITextField) {
        tryLogin()
    }
    
    @IBAction func loginButtonHandler(_ sender: UIButton) {
        tryLogin()
    }
   
    @IBAction func googleSIgnInHandler(_ sender: GIDSignInButton) {
        
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func viewTouchHandler(_ sender: UITapGestureRecognizer) {
        if isKeyboardUp { self.view.endEditing(true) }
    }
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self

        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: "ToggleAuthUINotification"), object: nil, queue: nil) { (noti) in
            self.alert(msg: "\(noti.userInfo)")
        }

        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardDidShow, object: nil, queue: nil) { (noti) in
            self.isKeyboardUp = true
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardDidHide, object: nil, queue: nil) { (noti) in
            self.isKeyboardUp = false
        }
    }

}

extension LoginViewController{
    private func save(loginResponse:LoginResponse, on userDefault:UserDefaults, completion:@escaping ()->Void){
        guard let userInfo = loginResponse.user,
            let authToken = loginResponse.token
        else { alert(msg: "통신이 제대로 이루어지지 않았습니다!"); return }
        
        guard let nickName = userInfo.nickname,
            let mainInstrument = userInfo.instrument,
            let userId = userInfo.id
        else { alert(msg: "통신이 제대로 이루어지지 않았습니다!"); return }
        userDefault.set(authToken, forKey: token)
        userDefault.set(nickName, forKey: nickname)
        userDefault.set(mainInstrument, forKey: instrument)
        userDefault.set(userId, forKey: id)
        completion()
    }
    
    private func tryLogin(){
        guard let email = emailTextField.text else {alert(msg: "Email");return}
        guard let password = passwordTextField.text else {alert(msg: "password is Invalid");return}
        
        NetworkController.main.login(with: email, and: password) {result in
            self.save(loginResponse: result, on: UserDefaults.standard, completion: {
                DispatchQueue.main.async(execute: {self.performSegue(withIdentifier: "loginSuccessSegue", sender: nil)})
            })
        }
    }
}

