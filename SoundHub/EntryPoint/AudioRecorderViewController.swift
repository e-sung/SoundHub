//
//  AudioRecorderViewController.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 12. 4..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit
import AVFoundation
import AudioKit
import AudioKitUI

class AudioRecorderViewController: UIViewController {

    
    // MARK: IBoutlets
    @IBOutlet weak private var recordButton: UIButton!
    @IBOutlet weak private var inputPlot: AKNodeOutputPlot!
    
    // MARK: IBActions
    @IBAction private func onScreenTouchHandler(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    @IBAction private func cancleButtonHandler(_ sender: UIBarButtonItem) {
        AudioKit.stop()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func recordButtonHandler(_ sender: UIButton) {
        
        switch state! {
        case .readyToRecord :
            makeRecordingState()
        case .recording :
            makeReadyToPlayState()
        case .readyToPlay :
            player.play()
            inputPlot.color = .orange
            inputPlot.node = player
            recordButton.setTitle("그만 듣고 업로드하기", for: .normal)
            state = .playing
        case .playing :
            player.stop()
            state = .readyToRecord
            recordButton.setTitle("녹음하기", for: .normal)
            let recordedDuration = player != nil ? player.audioFile.duration  : 0
            if recordedDuration > 0.0 {
                recorder.stop()
                showMetaInfoSetUpVC()
            }
        }
    }
    
    // MARK: Recording Related Stored Properties
    private let mic = AKMicrophone()
    private var micMixer:AKMixer!
    private var micBooster: AKBooster!
    private var recorder:AKNodeRecorder!
    private var player:AKAudioPlayer!
    private var moogLadder: AKMoogLadder!
    private var mainMixer: AKMixer!
    private var state:State!
    
    // MARK: Private Enum
    private enum State {
        case readyToRecord
        case recording
        case readyToPlay
        case playing
    }

    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpProperties()
        player.looping = true
        state = .readyToRecord
        AudioKit.start()
    }
}

// MARK: Helper Functions
extension AudioRecorderViewController{

    private func showMetaInfoSetUpVC(){
        let storyBoard = UIStoryboard(name: "Entry", bundle: nil)
        let metaInfoSetUpVC = storyBoard.instantiateViewController(withIdentifier: "SetUpMetaInfoViewController") as! SetUpMetaInfoViewController
        metaInfoSetUpVC.player = player
        present(metaInfoSetUpVC, animated: true, completion: nil)
    }
    

    private func setUpProperties(){
        setUpSession()
        setUpMic()
        setUpRecorder()
        setUpMixer()
    }
    
    private func setUpSession(){
        // Clean tempFiles !
        AKAudioFile.cleanTempDirectory()
        // Session settings
        AKSettings.bufferLength = .medium
        do { try AKSettings.setSession(category: .playAndRecord, with: .allowBluetoothA2DP) }
        catch { AKLog("Could not set session category.") }
        AKSettings.defaultToSpeaker = true
    }
    
    private func setUpMic(){
        // Patching
        inputPlot.node = mic
        micMixer = AKMixer(mic)
        micBooster = AKBooster(micMixer)
        // Will set the level of microphone monitoring
        micBooster.gain = 0
    }
    
    private func setUpRecorder(){
        recorder = try? AKNodeRecorder(node: micMixer)
        if let file = recorder.audioFile {
            player = try? AKAudioPlayer(file: file)
        }
    }
    
    private func setUpMixer(){
        moogLadder = AKMoogLadder(player)
        mainMixer = AKMixer(moogLadder, micBooster)
        AudioKit.output = mainMixer
    }
    
    
    private func makeRecordingState(){
        recordButton.setTitle("그만 녹음하기", for: .normal)
        inputPlot.color = .red
        state = .recording
        if AKSettings.headPhonesPlugged { micBooster.gain = 1 }
        do { try recorder.record() } catch { print("Errored recording.") }
    }
    
    private func makeReadyToPlayState(){
        recordButton.setTitle("들어보기", for: .normal)
        state = .readyToPlay
        inputPlot.color = .orange
        micBooster.gain = 0
        do { try player.reloadFile() } catch { print("Errored reloading.") }
    }
}
