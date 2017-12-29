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
    var token:String?
    var selectedInstruments = ""
    var nickName:String!
    var email:String!
    var password:String!
    var passwordConfirm:String!
    var defaultCellSize:CGSize!
    
    // MARK: Computed Properties

    @IBOutlet weak var mainFlowLayout: UICollectionView!
    // MARK: IBActions
    @IBAction func cancelButtonHandler(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirmButtonHandler(_ sender: UIButton) {
        for i in 0..<mainFlowLayout.allCells.count{
            if mainFlowLayout.allCells[i].isSelected{
                selectedInstruments += (Instrument.cases[i] + ",")
            }
        }
        let _ = selectedInstruments.dropLast()
        if let token = token {
            showLoadingIndicator()
            NetworkController.main.signUp(with: token, nickname: nickName, instruments: selectedInstruments, completion: { (dic, err) in
                if let userInfo = dic{
                    UserDefaults.standard.save(with: userInfo)
                    self.presentedViewController?.dismiss(animated: true, completion: {
                        self.performSegue(withIdentifier: "showMainChart", sender: nil)
                    })
                }else {
                    self.presentedViewController?.dismiss(animated: true, completion: {
                        if let err = err { self.present(self.generateAlert(given: err), animated: true, completion: nil)}
                        else{ self.alert(msg: "이건 무슨 오류일까요?") }
                    })
                }
            })
            
        }else{
            NetworkController.main.signUp(with: email, nickname: nickName, instruments: selectedInstruments, password1: password, password2: passwordConfirm) { (userId, errorMessage) in
                let alert = self.generateAlert(given: errorMessage)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    private func generateAlert(given error:String?)->UIAlertController{
        let alertMessage = self.generateAlertMessage(given: error)
        let alert = UIAlertController(title: "안내", message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .cancel , handler: { (action) in
            if let _ = error { self.dismiss(animated: true, completion: nil) }
            else { self.dismissWith(depth: 2, from: self) }
        }))
        return alert
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainFlowLayout.dataSource = self
        mainFlowLayout.delegate = self
        mainFlowLayout.allowsMultipleSelection = true
        defaultCellSize = CGSize(width: self.view.frame.width/3, height: self.view.frame.width/3)
    }
    
    private func generateAlertMessage(given errorMessage:String?)->String{
        if let error = errorMessage{ return error }
        else{ return "인증 메일을 보냈습니다! \n 확인해 보세요!  \n\n 참! 스팸으로 분류되었을 수도 있어요!" }
    }

}

extension ProfileSetUpViewController:UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Instrument.cases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "instrumentContainerCell", for: indexPath)
        let instrument = Instrument(rawValue: Instrument.cases[indexPath.item])!
        if instrument == .Other{
            let label = UILabel()
            cell.addSubview(label)
            label.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: defaultCellSize)
            label.text = "Others"
            label.font = label.font.withSize(30)
            label.textColor = .orange
            label.textAlignment = .center
            cell.backgroundColor = .black
            return cell
        }
        let imageView = UIImageView(image: instrument.image)
        cell.addSubview(imageView)
        imageView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: defaultCellSize)
        imageView.contentMode = .scaleAspectFill
        return cell
    }
}

extension ProfileSetUpViewController:UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return defaultCellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.borderColor = .green
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.borderColor = .orange
    }

}
