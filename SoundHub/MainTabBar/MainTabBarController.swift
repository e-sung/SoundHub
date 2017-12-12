//
//  MainTabBarController.swift
//  LoginPractice
//
//  Created by 류성두 on 2017. 11. 24..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController{
    var playBarController:PlayBarController!
    let uploadMusicButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.isHidden = true
        setUploadButton()
        self.view.addSubview(uploadMusicButton)
        playBarController = PlayBarController.main
        self.view.addSubview(playBarController.view)
        playBarController.setUpView(In: self.view)
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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

extension MainTabBarController{
    private func setUploadButton(){
        uploadMusicButton.frame = CGRect(x: self.view.frame.width - 70, y: self.view.frame.height - 80, width: 60, height: 60)
        uploadMusicButton.setTitle("+", for: .normal)
        uploadMusicButton.setTitleColor(.green, for: .normal)
        uploadMusicButton.titleLabel?.font = uploadMusicButton.titleLabel?.font.withSize(40)
        uploadMusicButton.addTarget(self, action: #selector(uploadButtonHandler), for: .touchUpInside)
    }
}


