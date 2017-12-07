//
//  UITableViewCell.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 12. 7..
//  Copyright © 2017년 류성두. All rights reserved.
//

import Foundation
import UIKit

extension UITableViewCell{
    func becomeAudioCommentCell(commentInfo:Comment, delegate:AudioCommentCellDelegate)->AudioCommentCell{
        let commentCell = self as! AudioCommentCell
        commentCell.commentInfo = commentInfo
        commentCell.delegate = delegate
        return commentCell
    }
    
    func becomeMasterWaveCell(with audioURL:URL, completion:@escaping (URL)->Void)->MasterWaveFormViewCell{
        let masterWaveCell = self as! MasterWaveFormViewCell
        NetworkController.main.downloadAudio(from: audioURL) { (localURL) in
            masterWaveCell.masterAudioURL = localURL
            completion(localURL)
        }
        return masterWaveCell
    }
    


}
