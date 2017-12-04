//
//  AudioRecorderViewController.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 12. 4..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit
import AudioKit
import AudioKitUI

class AudioRecorderViewController: UIViewController {

    
    @IBOutlet weak var recordButton: UIButton!
    
    @IBAction func cancleButtonHandler(_ sender: UIBarButtonItem) {
        AudioKit.stop()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func recordButtonHandler(_ sender: UIButton) {
        
        switch state {
        case .readyToRecord :
            recordButton.setTitle("Stop", for: .normal)
            state = .recording
            // microphone will be monitored while recording
            // only if headphones are plugged
            if AKSettings.headPhonesPlugged {
                micBooster.gain = 1
            }
            do {
                try recorder.record()
            } catch { print("Errored recording.") }
            
        case .recording :
            recordButton.setTitle("Play", for: .normal)
            state = .readyToPlay
            // Microphone monitoring is muted
            micBooster.gain = 0
            do {
                try player.reloadFile()
            } catch { print("Errored reloading.") }
            
            let recordedDuration = player != nil ? player.audioFile.duration  : 0
            if recordedDuration > 0.0 {
                recorder.stop()
                player.audioFile.exportAsynchronously(name: "TempTestFile.m4a",
                                                      baseDir: .documents,
                                                      exportFormat: .m4a) {_, exportError in
                                                        if let error = exportError {
                                                            print("Export Failed \(error)")
                                                        } else {
                                                            print("Export succeeded")
                                                        }
                }
            }
        case .readyToPlay :
            player.play()
            recordButton.setTitle("Stop", for: .normal)
            state = .playing
        case .playing :
            player.stop()
            recordButton.setTitle("Record", for: .normal)
            state = .readyToRecord
        default:
            print("unexpected item")
        }

        
    }
    @IBAction func stopRecordButtonHandler(_ sender: UIButton) {
        recorder.stop()
    }
    
    @IBAction func playButtonHandler(_ sender: UIButton) {
        player.play()
    }
    @IBOutlet weak var inputPlot: AKNodeOutputPlot!
    let mic = AKMicrophone()
    var micMixer:AKMixer!
    var micBooster: AKBooster!
    var recorder:AKNodeRecorder!
    var player:AKAudioPlayer!
    var moogLadder: AKMoogLadder!
    var mainMixer: AKMixer!
    var state:State!
    
    enum State {
        case readyToRecord
        case recording
        case readyToPlay
        case playing
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        // Clean tempFiles !
        AKAudioFile.cleanTempDirectory()
        
        // Session settings
        AKSettings.bufferLength = .medium
        
        do {
            try AKSettings.setSession(category: .playAndRecord, with: .allowBluetoothA2DP)
        } catch {
            AKLog("Could not set session category.")
        }
        
        AKSettings.defaultToSpeaker = true
        
        // Patching
        inputPlot.node = mic
        micMixer = AKMixer(mic)
        micBooster = AKBooster(micMixer)
        
        // Will set the level of microphone monitoring
        micBooster.gain = 0
        recorder = try? AKNodeRecorder(node: micMixer)
        if let file = recorder.audioFile {
            player = try? AKAudioPlayer(file: file)
        }
        player.looping = true

        
        moogLadder = AKMoogLadder(player)
        
        mainMixer = AKMixer(moogLadder, micBooster)
        
        state = .readyToRecord
        
        AudioKit.output = mainMixer
        AudioKit.start()
    }
}
