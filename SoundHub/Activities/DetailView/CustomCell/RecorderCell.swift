//
//  RecorderCell.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 12. 10..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit
import AudioKitUI

class RecorderCell: UITableViewCell {

    var delegate:DetailViewController?
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var inputPlot: AKNodeOutputPlot!
    override func awakeFromNib() {
        super.awakeFromNib()
        state = .readyToRecord
        inputPlot.node = RecordConductor.main.mic
    }
    
    @IBAction private func recordButtonHandler(_ sender: UIButton) {
        switch state! {
        case .readyToRecord :
            makeRecordingState()
        case .recording :
            makeReadyToPlayState()
        case .readyToPlay :
            RecordConductor.main.player.play()
            inputPlot.color = .orange
            inputPlot.node = RecordConductor.main.player
            recordButton.setTitle("확인", for: .normal)
            state = .playing
        case .playing :
            RecordConductor.main.player.stop()
            state = .readyToRecord
            recordButton.setTitle("녹음", for: .normal)
            let recordedDuration = RecordConductor.main.player != nil ? RecordConductor.main.player.audioFile.duration  : 0
            if recordedDuration > 0.0 {
                let alert = UIAlertController(title: "녹음 업로드", message: "녹음을 업로드 하시겠습니까?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .cancel , handler: { (action) in
                    let asset = RecordConductor.main.player.audioFile.avAsset
                    self.export(asset: asset)
                }))
                alert.addAction(UIAlertAction(title: "취소", style: .destructive, handler: { (action) in
                }))
                delegate?.present(alert, animated: true, completion: nil)
                RecordConductor.main.recorder.stop()
//                showMetaInfoSetUpVC()
            }
        }
    }
    
    // MARK: Private Enum
    private enum State {
        case readyToRecord
        case recording
        case readyToPlay
        case playing
    }
    
    private var state:State!

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    private func export(asset:AVAsset){
        let outputURL = URL(string: "comment.m4a".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)! , relativeTo: DataCenter.documentsDirectoryURL)!
        if let session = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A){
            session.outputFileType = AVFileType.m4a
            session.outputURL = outputURL
            session.exportAsynchronously {
                DispatchQueue.main.async(execute: {
                    let postId = self.delegate!.post.id
                    NetworkController.main.uploadAudioComment(In: outputURL, to: postId, instrument: "Guitar", completion: {
                        NetworkController.main.fetchPost(id: postId, completion: { (post) in
                            self.delegate?.post = post
                            self.delegate?.detailTV.reloadData()
                        })
                    })
                })
            }
        }else {
            print("AVAssetExportSession wasn't generated")
        }
    }

//    private func showMetaInfoSetUpVC(){
//        let storyBoard = UIStoryboard(name: "Entry", bundle: nil)
//        let metaInfoSetUpVC = storyBoard.instantiateViewController(withIdentifier: "SetUpMetaInfoViewController") as! SetUpMetaInfoViewController
//        metaInfoSetUpVC.player = RecordConductor.main.player
//        delegate?.present(metaInfoSetUpVC, animated: true, completion: nil)
//    }
    
    private func makeRecordingState(){
        recordButton.setTitle("중지", for: .normal)
        inputPlot.color = .red
        state = .recording
        delegate?.playMusic()
        RecordConductor.main.startRecording()
    }
    
    private func makeReadyToPlayState(){
        recordButton.setTitle("듣기", for: .normal)
        state = .readyToPlay
        inputPlot.color = .orange
        delegate?.pauseMusic()
        RecordConductor.main.stopRecording()
    }
    
}
