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
    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    @IBOutlet weak var emailLoginStackView: UIStackView!
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    
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
   
    @IBAction func googleSignInHandler(_ sender: GIDSignInButton) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func viewTouchHandler(_ sender: UITapGestureRecognizer) {
        if isKeyboardUp { self.view.endEditing(true) }
        else{ self.dismiss(animated: true, completion: nil) }
    }
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        googleSignInButton.colorScheme = .dark
        googleSignInButton.style = .wide
        tapGestureRecognizer.delegate = self
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: "ToggleAuthUINotification"), object: nil, queue: nil) { (noti) in
            if let dic = noti.userInfo as NSDictionary?{
                guard let token = dic["token"] as? String else { return }
                NetworkController.main.signIn(with: token, completion: { (result, error) in
                    if let err = error { self.alert(msg: err)}
                    guard let userInfo = result else { return }
                    UserDefaults.standard.save(with: userInfo)
                    self.performSegue(withIdentifier: "loginSuccessSegue", sender: nil)
                })
            }

        }

        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardDidShow, object: nil, queue: nil) { (noti) in
            self.isKeyboardUp = true
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardDidHide, object: nil, queue: nil) { (noti) in
            self.isKeyboardUp = false
        }
    }
}

extension LoginViewController:UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let y = touch.location(in: view).y
        return y < emailLoginStackView.frame.minY || y > googleSignInButton.frame.maxY
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
        userDefault.set(authToken, forKey: keyForToken)
        userDefault.set(nickName, forKey: keyForNickName)
        userDefault.set(mainInstrument, forKey: keyForInstruments)
        userDefault.set(userId, forKey: keyForUserId)
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

