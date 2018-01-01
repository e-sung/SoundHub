//
//  mainNavigationController.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 12. 21..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0

class mainNavigationController: UINavigationController {
    var playBarController:PlayBarController!
    var documentPicker:UIDocumentPickerViewController!
    let uploadMusicButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PlayBarController.reboot()
        playBarController = PlayBarController.main
        self.view.addSubview(playBarController.view)
        playBarController.setUpView(In: self.view)
        playBarController?.delegate = self
        self.view.addSubview(uploadMusicButton)
        setUploadButton()
        
        documentPicker = UIDocumentPickerViewController(documentTypes: ["public.audio"], in: UIDocumentPickerMode.import )
        documentPicker.delegate = self
    }
}

// MARK: Initialize Upload Button
extension mainNavigationController{
    private func setUploadButton(){
        let upLoadButtonWidth:CGFloat = 70
        uploadMusicButton.frame = CGRect(x: self.view.frame.width - upLoadButtonWidth, y: self.view.frame.height - upLoadButtonWidth, width: upLoadButtonWidth, height:upLoadButtonWidth)
        uploadMusicButton.setTitle("+", for: .normal)
        uploadMusicButton.setTitleColor(.green, for: .normal)
        uploadMusicButton.titleLabel?.font = uploadMusicButton.titleLabel?.font.withSize(40)
        uploadMusicButton.addTarget(self, action: #selector(uploadButtonHandler), for: .touchUpInside)
    }
    
    private func setUploadButtonAutoLayout(){
        uploadMusicButton.centerYAnchor.constraint(equalTo: playBarController.view.centerYAnchor).isActive = true
        uploadMusicButton.trailingAnchor.constraint(equalTo: playBarController.view.trailingAnchor, constant: -10).isActive = true
    }
    
    @objc func uploadButtonHandler(sender:UIButton){
        if User.isLoggedIn{
            let alert = UIAlertController(title: "어떻게 올리시겠습니까?", message: "", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "원래 있던 파일 올리기", style: .default , handler: { (action) in
                self.present(self.documentPicker, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "새로 녹음하기", style: .default , handler: { (action) in
                let storyboard = UIStoryboard(name: "UploadAudio", bundle: nil)
                let audioRecorderVC = storyboard.instantiateViewController(withIdentifier: "AudioRecorderViewController") as! AudioRecorderViewController
                self.present(audioRecorderVC, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { (action) in
            }))
            self.present(alert, animated: true, completion: nil)
        }else{
            alert(msg: "로그인이 필요한 기능입니다.")
        }
    }
}


extension mainNavigationController:PlayBarControllerDelegate{
    func playBarDidTapped() {
        if self.topViewController !== playBarController?.currentPostView{
            self.show((playBarController?.currentPostView)!, sender: nil)
        }
    }
}

extension mainNavigationController:UIDocumentPickerDelegate{
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        print(urls[0])
        ActionSheetStringPicker.ask(instrument: Instrument.cases, and: Genre.cases, of: urls[0], from: self)
    }
}
