//
//  UIViewController.swift
//  RaspberryAlarm
//
//  Created by 류성두 on 2017. 11. 18..
//  Copyright © 2017년 류성두. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController{
    /**
     UIAlertController 를 쉽게 쓰게 만드는 함수.
     */
    func alert(msg:String){
        let alert = UIAlertController(title: "안내", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .cancel , handler: { (action) in
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func dismissWith(depth:Int, from vc:UIViewController){
        if depth == 0 {
            return
        }
        
        if let pvc = vc.presentingViewController {
            vc.dismiss(animated: true, completion: {
                self.dismissWith(depth: depth - 1, from: pvc)
            })
        }else{
            vc.dismiss(animated: true, completion: nil)
        }
    }
}
