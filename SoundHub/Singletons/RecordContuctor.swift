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
    /// 녹음과 관련된 모든 것을 담당하는 싱글턴 객체
    public static let main = RecordConductor()
    
    private var micMixer:AKMixer!
    private var moogLadder: AKMoogLadder!
    private var mic: AKMicrophone!
    private var micBooster: AKBooster!
    private var recorder:AKNodeRecorder!
    /// 녹음된 소리를 재생함
    var player:AKAudioPlayer!
    /// AudioKit 엔진의 최종 Output Node
    var mainMixer: AKMixer!

    init(){ bootUp() }
    private func bootUp(){
        setUpSession()
        setUpMic()
        setUpRecorderAndPlayer()
        setUpMixer()
        startEngine()
    }
    private func startEngine(){ AudioKit.start() }
    private func stopEngine(){ AudioKit.stop() }
    
}

// MARK: Boot Up
extension RecordConductor{
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

// MARK: Internal Functions
extension RecordConductor{

    func startRecording(){
        if AKSettings.headPhonesPlugged { self.micBooster.gain = 1 }
        do { try self.recorder.record() } catch { print("Errored recording.") }
    }
    
    func stopRecording(){ self.recorder.stop() }
    
    func resetPlayer(){
        self.micBooster.gain = 0
        do { try self.player.reloadFile() } catch { print("Errored reloading.") }
    }
    
    func resetRecorder(){
        do{ try recorder.reset() } catch { print("couldn't reset recorded audio") }
    }
    
    func confirmComment(on postId:Int, of Instrument:String, completion:@escaping (Post?)->Void){
        if self.player.duration == 0 { completion(nil) }
        let asset = RecordConductor.main.player.audioFile.avAsset
        self.exportComment(asset: asset, completion: { (outputURL) in
            NetworkController.main.uploadAudioComment(In: outputURL, to: postId, instrument: Instrument, completion: {
                NetworkController.main.fetchPost(id: postId, completion: { (postResult) in
                    completion(postResult)
                    DispatchQueue.global(qos: .userInitiated).async { self.resetRecorder() }
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
            session.exportAsynchronously { DispatchQueue.main.async { completion() } }
        }else { print("AVAssetExportSession wasn't generated") }
    }
    
    /// 입력으로 주어진 asset을 .m4a파일로 export 합니다
    private func exportComment(asset:AVAsset, completion:@escaping(_ output:URL)->Void){
        let outputURL = URL(string: "comment.m4a".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)! , relativeTo: DataCenter.documentsDirectoryURL)!
        if let session = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A){
            session.outputFileType = AVFileType.m4a
            session.outputURL = outputURL
            session.exportAsynchronously { DispatchQueue.main.async(execute: { completion(outputURL) }) }
        }else { print("AVAssetExportSession wasn't generated") }
    }
    
    /// RecordConductor 가 가지고 있는 mic객체와 outPutPlot의 Node를 연결시킴
    /// - parameter outPutPlot : Mic에 들어오는 음악의 파형을 표현할 AKNodeOutputPlot 객체
    func connectMic(with outPutPlot:AKNodeOutputPlot){
        outPutPlot.node = self.mic
    }
}
