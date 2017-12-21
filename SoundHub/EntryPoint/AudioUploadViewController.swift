
//
//  AudioUploadViewController.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 12. 1..
//  Copyright © 2017년 류성두. All rights reserved.
//

import Foundation
import AVFoundation
import LPSnackbar
import UIKit

class AudioUploadViewController: UIViewController {
    
    var audioURL:URL?
    var genre:String!
    var instrument:String!
    private let imagePicker = UIImagePickerController()
    @IBOutlet weak private var audioTitleTF:UITextField!
    @IBOutlet weak private var albumArt: UIButton!
    @IBOutlet weak private var authorNameLB: UILabel!
    @IBAction private func cancelHandler(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onAlbumArtClickHandler(_ sender: UIButton) {
        present(photoSourceChooingAlert, animated: true, completion: nil)
    }
    @IBAction func onViewTouchHandler(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction private func uploadHandler(_ sender: UIButton) {
        
        if let audioURL = audioURL{
            self.dismiss(animated: true, completion: nil)
            //        NetworkController.main.uploadAudio(In: audioURL, genre: genre, instrument: instrument) {
            //
            //        }
            
        }else{
            let audioTitle = audioTitleTF.text ?? "Untitled"
            let titleMetadata = String.generateAvMetaData(with: audioTitle,
                                                          and: .commonIdentifierTitle)
            let artistMetadata = String.generateAvMetaData(with: authorNameLB.text!,
                                                           and: .commonIdentifierArtist)
            let exportURL = URL(string: "\(audioTitle).m4a".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)! , relativeTo: DataCenter.documentsDirectoryURL)!
            self.dismissWith(depth: 2, from: self, completion: {
                LPSnackbar.showSnack(title: "Exporting...")
            })
            
//            RecordConductor.main.exportRecordedAudio(to: exportURL,
//                                                     with: [titleMetadata, artistMetadata], completion: {
//                NetworkController.main.uploadAudio(In: exportURL, genre: genre, instrument: instrument, completion: {
//
//                })
//            })
        }
    }

    private func setUpUI(with audio:AVPlayerItem){
        for item in audio.asset.metadata{
            if let key = item.commonKey, let value = item.value {
                if key == .commonKeyArtwork, let data = value as? Data{
                    albumArt.setImage(UIImage(data: data), for: .normal)
                    albumArt.isUserInteractionEnabled = false
                }
                else if key == .commonKeyTitle {
                    audioTitleTF.text = value as? String
                    audioTitleTF.isUserInteractionEnabled = false
                }
                else if key == .commonKeyArtist {
                    authorNameLB.text = value as? String
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        authorNameLB.text = UserDefaults.standard.string(forKey: nickname)
        audioTitleTF.becomeFirstResponder()
        guard let audioURL = audioURL else { return }
        let playerItem = AVPlayerItem(url: audioURL)
        setUpUI(with: playerItem)
    }
    
    private var defaultUIAlertActions:[UIAlertAction]{
        get{
            let withExistingPhoto = UIAlertAction(title: "원래 있던 사진으로", style: .default , handler: { (action) in
                self.imagePicker.sourceType = .photoLibrary
                self.present(self.imagePicker, animated: true, completion: nil)
            })
            
            let withNewPhoto = UIAlertAction(title: "새로 사진 찍어서", style: .default , handler: { (action) in
                self.imagePicker.sourceType = .camera
                self.present(self.imagePicker, animated: true, completion: nil)
            })
            
            let cancel = UIAlertAction(title: "취소", style: .cancel) { (action) in
                self.presentedViewController?.dismiss(animated: true, completion: nil)
            }
            return [withExistingPhoto, withNewPhoto, cancel]
        }
    }
    
    private var photoSourceChooingAlert:UIAlertController{
        get{
            let alert = UIAlertController(title: "사진 변경", message: "", preferredStyle: .actionSheet)
            let actions = defaultUIAlertActions
            for action in actions{
                alert.addAction(action)
            }
            return alert
        }
    }
}

// MARK: ImagePickerDelegate
extension AudioUploadViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            albumArt.setImage(pickedImage, for: .normal)
            albumArt.imageView?.contentMode = .scaleAspectFill
        }
        dismiss(animated: true, completion: nil)
    }
}
