//
//  MainTabBarController.swift
//  LoginPractice
//
//  Created by 류성두 on 2017. 11. 24..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController{
    let playBarController:PlayBarController = PlayBarController()
    let mainTabBarView = UIView()
    let uploadMusicButton = UIButton()
    let tabBarItems:[UIImage] = [#imageLiteral(resourceName: "play"),#imageLiteral(resourceName: "stop")]
    var tabBarButtons:[UIButton] = []
    
    private var heightOfTabBar:CGFloat!
    private var widthOfButton:CGFloat!
    
    override func viewDidLoad() {
        initializeGlobalProperties()
        setUploadButton()
        self.view.addSubview(uploadMusicButton)
        setUpperTabBar()
//        setUpSwipeRecognizer()
        self.tabBar.isHidden = true
    }
    
    @objc func swipeHandler(sender:UISwipeGestureRecognizer){
        if sender.direction == .up {hideTabBar()}
        else if sender.direction == .down{showTabBar()}
    }
    
    @objc func changeTabbar(sender:UIButton) {
        let tabBarButtons = self.tabBarButtons
        for button in tabBarButtons{button.isSelected = false}
        sender.isSelected = true
        self.selectedIndex = sender.tag
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
    private func initializeGlobalProperties(){
        widthOfButton = (self.view.frame.width)/2.0
        heightOfTabBar = CGFloat(60)
    }
    
    private func setUploadButton(){
        uploadMusicButton.frame = CGRect(x: self.view.frame.width - 70, y: self.view.frame.height-(70 + heightOfTabBar), width: 60, height: 60)
        uploadMusicButton.setTitle("+", for: .normal)
        uploadMusicButton.setTitleColor(.green, for: .normal)
        uploadMusicButton.titleLabel?.font = uploadMusicButton.titleLabel?.font.withSize(40)
        uploadMusicButton.addTarget(self, action: #selector(uploadButtonHandler), for: .touchUpInside)
    }
    
    private func setUpperTabBar(){
        mainTabBarView.frame = CGRect(x: 0, y: self.view.frame.height - heightOfTabBar, width: self.view.frame.width, height: heightOfTabBar)
        mainTabBarView.backgroundColor = .black
        self.view.addSubview(mainTabBarView)
        
        let buttonSize = CGSize(width: heightOfTabBar*0.8, height: heightOfTabBar*0.8)
        let playButton = UIButton()
        let playButtonOrigin = CGPoint(x: mainTabBarView.frame.width/2 - buttonSize.width, y: heightOfTabBar*0.2)
        playButton.frame = CGRect(origin: playButtonOrigin, size: buttonSize)
        playButton.setBackgroundImage(#imageLiteral(resourceName: "play"), for: .normal)
        playButton.isEnabled = false
        playBarController.playButton = playButton
        mainTabBarView.addSubview(playButton)
        
        let stopButton = UIButton()
        stopButton.setBackgroundImage(#imageLiteral(resourceName: "stop"), for: .normal)
        let stopButtonOrigin = CGPoint(x: mainTabBarView.frame.width/2, y: heightOfTabBar*0.2)
        stopButton.frame = CGRect(origin: stopButtonOrigin, size: buttonSize)
        stopButton.isEnabled = false
        playBarController.stopButton = stopButton
        mainTabBarView.addSubview(stopButton)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(showCurrentPlayingPost))
        mainTabBarView.addGestureRecognizer(tapRecognizer)
        mainTabBarView.isHidden = true
    }
    
    @objc func showCurrentPlayingPost(){
        if let currentPlayingVC = playBarController.currentPostView{
//            let storyboard = UIStoryboard(name: "GeneralRanking", bundle: nil)
//            let rootVC = storyboard.instantiateViewController(withIdentifier: "ChartViewController") as! UIViewController
//            rootVC.navigationController?.pushViewController(currentPlayingVC, animated: true)
        }
    }

    private func setUpSwipeRecognizer(){
        let swipeUpRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeHandler))
        swipeUpRecognizer.direction = .up
        self.view.addGestureRecognizer(swipeUpRecognizer)
        
        let swipeDownRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeHandler))
        swipeDownRecognizer.direction = .down
        self.view.addGestureRecognizer(swipeDownRecognizer)
    }
}

extension MainTabBarController{
    private func generateArrayOfButtons(with count:Int)->[UIButton]{
        var buttonsToReturn:[UIButton] = []
        for _ in 0..<count{
            buttonsToReturn.append(UIButton())
        }
        return buttonsToReturn
    }
    
    private func hideTabBar(){
        UIView.animate(withDuration: 0.3) {self.mainTabBarView.setHeight(with: 0)}
        UIView.animate(withDuration: 0.3) {for button in self.tabBarButtons {button.alpha = 0}}
    }
    
    private func showTabBar(){
        UIView.animate(withDuration: 0.3, animations: {self.mainTabBarView.setHeight(with: self.heightOfTabBar)})
        UIView.animate(withDuration: 0.3) {for button in self.tabBarButtons {button.alpha = 1}}
    }
}

extension UIView{
    func setHeight(with height:CGFloat){
        self.frame = CGRect(x: self.frame.minX, y: self.frame.minY, width: self.frame.width, height: height)
    }
}

