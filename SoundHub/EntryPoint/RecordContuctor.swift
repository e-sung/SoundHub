//
//  RecordContuctor.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 12. 6..
//  Copyright © 2017년 류성두. All rights reserved.
//

import Foundation
import AudioKit
import AudioKitUI

class RecordConductor{
    public static let main = RecordConductor()
    
    private var micMixer:AKMixer!
    private var moogLadder: AKMoogLadder!
    private var mainMixer: AKMixer!
    
    var mic: AKMicrophone!
    var micBooster: AKBooster!
    var recorder:AKNodeRecorder!
    var player:AKAudioPlayer!
    
    init(){
        setUpSession()
        setUpMic()
        setUpRecorderAndPlayer()
        setUpMixer()
        start()
    }
    
    func start(){
        AudioKit.start()
    }
    
    func stop(){
        AudioKit.stop()
    }
    
    func startRecording(){
        if AKSettings.headPhonesPlugged { self.micBooster.gain = 1 }
        do { try self.recorder.record() } catch { print("Errored recording.") }
    }
    
    func stopRecording(){
        self.micBooster.gain = 0
        do { try self.player.reloadFile() } catch { print("Errored reloading.") }
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
        mic = AKMicrophone()
        micMixer = AKMixer(mic)
        micBooster = AKBooster(micMixer)
        // Will set the level of microphone monitoring
        micBooster.gain = 0
    }
    
    private func setUpRecorderAndPlayer(){
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
}
