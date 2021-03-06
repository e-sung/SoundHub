//
//  UIViewController.swift
//  RaspberryAlarm
//
//  Created by 류성두 on 2017. 11. 18..
//  Copyright © 2017년 류성두. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    /**
     JavaScript Style Alert
     */
    func alert(msg: String) {
        let alert = UIAlertController(title: "안내", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .cancel, handler: { (action) in
        }))
        self.present(alert, animated: true, completion: nil)
    }

    func showLoadingIndicator() {
        guard let indicatorVC = UIStoryboard(name: "Chart", bundle: nil)
                                .instantiateViewController(withIdentifier: "LoadingIndicatorViewController")
                                as? LoadingIndicatorViewController else { return }
        indicatorVC.modalPresentationStyle = .overCurrentContext
        indicatorVC.modalTransitionStyle = .crossDissolve
        self.present(indicatorVC, animated: true, completion: nil)
    }

    func showSideMenu() {
        let sb = UIStoryboard(name: "SideMenu", bundle: nil)
        let sideMenuVC = sb.instantiateViewController(withIdentifier: "SideMenu")
        present(sideMenuVC, animated: true, completion: nil)
    }

    /**
     최상단의 ViewController부터 depth만큼 스택에 쌓인 ViewController를 dismiss하는 함수
     - parameter depth : 스택에서 빼내고자 하는 ViewController의 개수
     - parameter currentVC : 현시점 스택의 최상단 ViewController
     */
    func dismissWith(depth: Int, from currentVC: UIViewController) {
        if depth == 0 { return }

        if let pvc = currentVC.presentingViewController {
            currentVC.dismiss(animated: true, completion: {
                self.dismissWith(depth: depth - 1, from: pvc)
            })
        }else{
            currentVC.dismiss(animated: true, completion: nil)
        }
    }
    /**
     최상단의 ViewController부터 depth만큼 스택에 쌓인 ViewController를 dismiss하는 함수
     - parameter depth : 스택에서 빼내고자 하는 ViewController의 개수
     - parameter currentVC : 현시점 스택의 최상단 ViewController
     */
    func dismissWith(depth: Int, from currentVC: UIViewController, completion: @escaping() -> Void) {
        if depth == 0 { completion(); return }

        if let pvc = currentVC.presentingViewController {
            currentVC.dismiss(animated: true, completion: {
                self.dismissWith(depth: depth - 1, from: pvc)
            })
        }else{
            currentVC.dismiss(animated: true, completion: nil)
        }
    }
}
