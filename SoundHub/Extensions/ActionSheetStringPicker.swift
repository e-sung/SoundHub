//
//  ActionSheetStringPicker.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 12. 21..
//  Copyright © 2017년 류성두. All rights reserved.
//

import Foundation
import ActionSheetPicker_3_0

extension ActionSheetStringPicker{
    static func ask(instrument:[String], and genre:[String], of url:URL, from vc:UIViewController){
        let storyBoard = UIStoryboard(name: "Entry", bundle: nil)
        let audioUploadVC = storyBoard.instantiateViewController(withIdentifier: "DocumentViewController") as! AudioUploadViewController
        audioUploadVC.audioURL = url
        ActionSheetStringPicker.show(withTitle: "어떤 악기인가요?", rows: instrument, initialSelection: 0, doneBlock: { (picker, row, result) in
            
            audioUploadVC.instrument = instrument[row]
            ActionSheetStringPicker.show(withTitle: "어떤 장르인가요?", rows: genre, initialSelection: 0, doneBlock: { (picker, row, result) in
                audioUploadVC.genre = genre[row]
                vc.present(audioUploadVC, animated: true, completion: nil)
            }, cancel: { (picker) in
            }, origin: vc.view)
        }, cancel: { (picker) in
        }, origin: vc.view)
    }

}
