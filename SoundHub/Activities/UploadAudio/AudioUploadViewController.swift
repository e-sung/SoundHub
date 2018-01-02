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

    var audioURL: URL?
    var genre: String!
    var instrument: String!
    private let imagePicker = UIImagePickerController()
    private var pickedImage = #imageLiteral(resourceName: "no_cover")
    @IBOutlet weak private var audioTitleTF: UITextField!
    @IBOutlet weak private var bpmTF: UITextField!
    @IBOutlet weak private var albumArt: UIButton!
    @IBOutlet weak private var cameraButton: UIButton!
    @IBOutlet weak private var authorNameLB: UILabel!
    @IBAction private func cancelHandler(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction private func onAlbumArtClickHandler(_ sender: UIButton) {
        present(photoSourceChooingAlert, animated: true, completion: nil)
    }
    @IBAction private func onViewTouchHandler(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    @IBAction private func uploadHandler(_ sender: UIButton) {
        let bpm = Int(bpmTF.text ?? "110") ?? 110
        if let audioURL = audioURL {
            uploadExisting(music: audioURL, with: bpm)
        }else {
            exportAndUpload(with: bpm)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        authorNameLB.text = UserDefaults.standard.string(forKey: keyForNickName)
        audioTitleTF.becomeFirstResponder()
        guard let audioURL = audioURL else { return }
        let playerItem = AVPlayerItem(url: audioURL)
        setUpUI(with: playerItem)
    }
}

extension AudioUploadViewController {
    private func setUpUI(with audio: AVPlayerItem) {
        for item in audio.asset.metadata {
            setUp(bpmTF, with: item)
            if let key = item.commonKey, let value = item.value {
                setUp(authorNameLB, with: key, and: value)
                setUp(audioTitleTF, with: key, and: value)
                setUp(albumArt, with: key, and: value)
            }
        }
    }

    private func setUp(_ label: UILabel, with key: AVMetadataKey, and value: NSCopying&NSObjectProtocol) {
        if key == .commonKeyArtist {
            label.text = value as? String
        }
    }

    private func setUp(_ textField: UITextField, with key: AVMetadataKey, and value: NSCopying&NSObjectProtocol) {
        if key == .commonKeyTitle {
            textField.text = value as? String
            textField.isUserInteractionEnabled = false
        }
    }

    private func setUp(_ albumButton: UIButton, with key: AVMetadataKey, and value: NSCopying&NSObjectProtocol) {
        if key == .commonKeyArtwork, let data = value as? Data {
            pickedImage = UIImage(data: data)!
            albumButton.setImage(UIImage(data: data), for: .normal)
            albumButton.isUserInteractionEnabled = false
            cameraButton.isHidden = true
        }
    }

    private func setUp(_ textField: UITextField, with metadata: AVMetadataItem) {
        if let identifier = metadata.identifier {
            if identifier == .iTunesMetadataBeatsPerMin || identifier == .id3MetadataBeatsPerMinute {
                textField.text = "\(metadata.value as! Int)"
                textField.isUserInteractionEnabled = false
            }
        }else if let key = metadata.commonKey, let value = metadata.value {
            if key == .id3MetadataKeyBeatsPerMinute || key == .iTunesMetadataKeyBeatsPerMin {
                textField.text = value as? String
                textField.isUserInteractionEnabled = false
            }
        }
    }
}

extension AudioUploadViewController {
    private func exportAndUpload(with bpm: Int) {
        showLoadingIndicator()
        RecordConductor.main.exportRecordedAudio(to: self.exportURL,
                                                 with: [self.titleMetaData, self.artistMetaData], completion: {
            NetworkController.main.uploadAudio(In: self.exportURL, title: self.audioTitleTF.text ?? "무제", genre: self.genre, instrument: self.instrument, bpm: bpm, albumCover: self.pickedImage, completion: {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name("shouldReloadContents"), object: nil)
                    self.presentedViewController?.dismiss(animated: true, completion: { self.dismissWith(depth: 2, from: self) })
                }
                RecordConductor.main.resetRecorder()
                RecordConductor.main.resetPlayer()
            })
        })
    }

    private func uploadExisting(music audioURL: URL, with bpm: Int) {
        showLoadingIndicator()
        NetworkController.main.uploadAudio(In: audioURL, title: audioTitleTF.text ?? "무제", genre: self.genre, instrument: self.instrument, bpm: bpm, albumCover: (self.albumArt.currentImage ?? #imageLiteral(resourceName: "no_cover") ), completion: {
            NotificationCenter.default.post(name: NSNotification.Name("shouldReloadContents"), object: nil)
            self.presentedViewController?.dismiss(animated: true, completion: {
                self.dismiss(animated: true, completion: nil)
            })
        })
    }
}

extension AudioUploadViewController {
    private var exportURL: URL {
        let title = audioTitleTF.text ?? "Untitled"
        return URL(string: "\(title).m4a".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)!, relativeTo: DataCenter.documentsDirectoryURL)!
    }

    private var titleMetaData: AVMutableMetadataItem {
        let title = audioTitleTF.text ?? "Untitled"
        return String.generateAvMetaData(with: title, and: .commonIdentifierTitle)
    }

    private var artistMetaData: AVMutableMetadataItem {
        let artistName = authorNameLB.text!
        return String.generateAvMetaData(with: artistName, and: .commonIdentifierArtist)
    }

    private var defaultUIAlertActions: [UIAlertAction] {
        let withExistingPhoto = UIAlertAction(title: "원래 있던 사진으로", style: .default, handler: { (action) in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        })

        let withNewPhoto = UIAlertAction(title: "새로 사진 찍어서", style: .default, handler: { (action) in
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        })

        let cancel = UIAlertAction(title: "취소", style: .cancel) { (action) in
            self.presentedViewController?.dismiss(animated: true, completion: nil)
        }
        return [withExistingPhoto, withNewPhoto, cancel]
    }

    private var photoSourceChooingAlert: UIAlertController {
        let alert = UIAlertController(title: "사진 변경", message: "", preferredStyle: .actionSheet)
        let actions = defaultUIAlertActions
        for action in actions { alert.addAction(action) }
        return alert
    }
}

// MARK: ImagePickerDelegate
extension AudioUploadViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.pickedImage = pickedImage
            albumArt.setImage(pickedImage, for: .normal)
            albumArt.imageView?.contentMode = .scaleAspectFill
        }
        dismiss(animated: true, completion: nil)
    }
}
