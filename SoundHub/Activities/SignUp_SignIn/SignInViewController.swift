//
//  SignInViewController.swift
//
//  Created by 류성두 on 2017. 11. 24..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit
import GoogleSignIn

class SignInViewController: UIViewController, UITextViewDelegate,GIDSignInUIDelegate {
    
    // MARK: Stored Properties
    var isKeyboardUp = false
    
    // MARK: IBOutlests
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var googleSignInButton: UIButton!
    @IBOutlet weak var emailLoginStackView: UIStackView!
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    
    // MARK: IBActions
    @IBAction func emailPrimaryActionHandler(_ sender: UITextField) {
        sender.resignFirstResponder()
        passwordTextField.becomeFirstResponder()
    }
    
    @IBAction func passwordPriamryActionHandler(_ sender: UITextField) {
        tryLogin(with: emailTextField.text, and: passwordTextField.text)
    }
    
    @IBAction func loginButtonHandler(_ sender: UIButton) {
        tryLogin(with: emailTextField.text, and: passwordTextField.text)
    }
   
    @IBAction func googleSignInHandler(_ sender: UIButton) {
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
        tapGestureRecognizer.delegate = self
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: "ToggleAuthUINotification"), object: nil, queue: nil) { (noti) in
            if let dic = noti.userInfo as NSDictionary?{
                guard let token = dic["token"] as? String else { return }
                self.tryLogin(with: token)
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

extension SignInViewController:UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let y = touch.location(in: view).y
        return y < emailLoginStackView.frame.minY || y > googleSignInButton.frame.maxY
    }
}

extension SignInViewController{
    private func tryLogin(with email:String?, and password:String?){
        guard let email = email else {alert(msg: "이메일을 입력하세요");return}
        guard let password = password else {alert(msg: "비밀번호를 입력하세요");return}
        self.showLoadingIndicator()
        NetworkController.main.signIn(with: email, and: password) { (result, error) in
            self.handle(result: result, and: error)
        }
    }
    private func tryLogin(with token:String){
        self.showLoadingIndicator()
        NetworkController.main.signIn(with: token, completion: { (result, error) in
            self.handle(result: result, and: error)
        })
    }
    
    private func handle(result:NSDictionary?, and error:String?){
        if let userInfo = result{
            UserDefaults.standard.save(with: userInfo)
            self.presentedViewController?.dismiss(animated: true, completion: {
                self.performSegue(withIdentifier: "loginSuccessSegue", sender: nil)
            })
        }else{
            self.presentedViewController?.dismiss(animated: true, completion: {
                if let err = error { self.alert(msg: err)}
                else{ self.alert(msg: "이런 오류가 있을줄이야..") }
            })
        }
    }
}

