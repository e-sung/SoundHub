//
//  ProfileSetUpViewController.swift
//  soundHubPractice
//
//  Created by 류성두 on 2017. 11. 27..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit

class ProfileSetUpViewController: UIViewController {

    // MARK: Stored Properties
    var selectedInstrument:Instrument?
    var nickName:String!
    var email:String!
    var password:String!
    var passwordConfirm:String!
    
    // MARK: Computed Properties
    var signupRequest:signUpRequest{
        get{
            return signUpRequest(email: email, nickname: nickName, instrument: selectedInstrument!.rawValue, password1: password, password2: passwordConfirm)
        }
    }
    
    // MARK: IBActions
    @IBAction func onTapHandler(_ sender: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func micButtonHandler(_ sender: UIButton) {
        selectedInstrument = .Vocal
        NetworkController.main.sendRequest(with: self.signupRequest, from: self)
    }
    @IBAction func guitarButtonHandler(_ sender: UIButton) {
        selectedInstrument = .Guitar
        NetworkController.main.sendRequest(with: self.signupRequest, from: self)
    }
    @IBAction func bassButtonHandler(_ sender: UIButton) {
        selectedInstrument = .Bass
        NetworkController.main.sendRequest(with: self.signupRequest, from: self)
    }
    @IBAction func keyboardButtonHandler(_ sender: UIButton) {
        selectedInstrument = .Keyboard
        NetworkController.main.sendRequest(with: self.signupRequest, from: self)
    }
    
    @IBAction func drumButtonHandler(_ sender: UIButton) {
        selectedInstrument = .Drum
        NetworkController.main.sendRequest(with: self.signupRequest, from: self)
    }
    @IBAction func otherButtonHandler(_ sender: UIButton) {
        selectedInstrument = .Other
        NetworkController.main.sendRequest(with: self.signupRequest, from: self)
    }

}
