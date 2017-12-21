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
    
    var mic: AKMicrophone!
    var micBooster: AKBooster!
    var recorder:AKNodeRecorder!
    var player:AKAudioPlayer!
    var mainMixer: AKMixer!

    
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
    
    func exportComment(asset:AVAsset, completion:@escaping(_ output:URL)->Void){
        let outputURL = URL(string: "comment.m4a".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)! , relativeTo: DataCenter.documentsDirectoryURL)!
        if let session = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A){
            session.outputFileType = AVFileType.m4a
            session.outputURL = outputURL
            session.exportAsynchronously {
                DispatchQueue.main.async(execute: {
                    completion(outputURL)
                })
            }
        }else {
            print("AVAssetExportSession wasn't generated")
        }
    }
    
    func confirmComment(on postId:Int, of Instrument:String, completion:@escaping (Post?)->Void){
        if self.player.duration == 0 { completion(nil) }
        let asset = RecordConductor.main.player.audioFile.avAsset
        self.exportComment(asset: asset, completion: { (outputURL) in
            NetworkController.main.uploadAudioComment(In: outputURL, to: postId, instrument: Instrument, completion: {
                NetworkController.main.fetchPost(id: postId, completion: { (postResult) in
                    DispatchQueue.main.async { completion(postResult) }
                })
            })
        })
    }
    func exportRecordedAudio(to url:URL, with metadatas:[AVMetadataItem], completion:@escaping ()->Void){
        if let session = AVAssetExportSession(asset: self.player.audioFile.avAsset,
                                              presetName: AVAssetExportPresetAppleM4A){
            session.metadata = metadatas
            session.outputFileType = AVFileType.m4a
            session.outputURL = url
            session.exportAsynchronously {
                completion()
            }
        }else {
            print("AVAssetExportSession wasn't generated")
        }
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
