//
//  mainNavigationController.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 12. 21..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit

class mainNavigationController: UINavigationController {
    var playBarController:PlayBarController!
    let uploadMusicButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playBarController = PlayBarController.main
        self.view.addSubview(playBarController.view)
        playBarController.setUpView(In: self.view)
        playBarController?.delegate = self
        setUploadButton()
        self.view.addSubview(uploadMusicButton)

        // Do any additional setup after loading the view.
    }

    private func setUploadButton(){
        let upLoadButtonWidth:CGFloat = 70
        uploadMusicButton.frame = CGRect(x: self.view.frame.width - upLoadButtonWidth, y: self.view.frame.height - upLoadButtonWidth, width: upLoadButtonWidth, height:upLoadButtonWidth)
        uploadMusicButton.setTitle("+", for: .normal)
        uploadMusicButton.setTitleColor(.green, for: .normal)
        uploadMusicButton.titleLabel?.font = uploadMusicButton.titleLabel?.font.withSize(40)
        uploadMusicButton.addTarget(self, action: #selector(uploadButtonHandler), for: .touchUpInside)
    }
    
    @objc func uploadButtonHandler(sender:UIButton){
        let alert = UIAlertController(title: "어떻게 올리시겠습니까?", message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "원래 있던 파일 올리기", style: .default , handler: { (action) in
            let storyboard = UIStoryboard(name: "Entry", bundle: nil)
            let documentBrowserVC = storyboard.instantiateViewController(withIdentifier: "DocumentBrowserController") as! DocumentBrowserViewController
            self.present(documentBrowserVC, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "새로 녹음하기", style: .default , handler: { (action) in
            let storyboard = UIStoryboard(name: "Entry", bundle: nil)
            let audioRecorderVC = storyboard.instantiateViewController(withIdentifier: "AudioRecorderViewController") as! AudioRecorderViewController
            self.present(audioRecorderVC, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { (action) in
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
extension mainNavigationController:PlayBarControllerDelegate{
    func playBarDidTapped() {
        if self.topViewController !== playBarController?.currentPostView{
            self.show((playBarController?.currentPostView)!, sender: nil)
        }
    }
}
