//
//  DetailViewController.swift
//  soundHubPractice
//
//  Created by 류성두 on 2017. 11. 26..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit
import AudioKit
import AVFoundation

class DetailViewController: UIViewController{
    
    // MARK: Stored Properties
    var post:Post!
    var masterWaveCell:MasterWaveFormViewCell!
    var mixedCommentsContainer : MixedTracksContainerCell!
    var masterAudioRemoteURL:URL!
    private var currentPhase = Phase.Ready
    var currentInstrument:String?
    
    var masterPlayer:AVPlayer!
    private var playMode:PlayMode = .mixed
    
    private enum PlayMode{
        case master
        case mixed
    }
    
    // MARK: IBOutlets
    @IBOutlet weak private var detailTV: UITableView!
    @IBOutlet weak private var playButton: UIButton!
    
    // MARK: IBActions
    @IBAction private func playButtonHandler(_ sender: UIButton) {
        if currentPhase == .Ready {
            sender.setImage(#imageLiteral(resourceName: "ic_pause_circle_outline_white"), for: .normal)
            currentPhase = .Playing
            mixedCommentsContainer.playMusic()
//            playMusic()
        }else if currentPhase == .Playing{
            sender.setImage(#imageLiteral(resourceName: "ic_play_circle_outline_white"), for: .normal)
            currentPhase = .Ready
            mixedCommentsContainer.pauseMusic()
//            pauseMusic()
        }
    }
    
//    @IBAction func recordButtonHandler(_ sender: UIButton) {
//        if currentPhase != .Recording {
//            currentPhase = .Recording
//            playMusic()
//            RecordConductor.main.startRecording()
//        }else{
//            currentPhase = .Ready
//            pauseMusic()
//            RecordConductor.main.stopRecording()
//            RecordConductor.main.player.play()
//        }
//    }

    // MARK: Obserable Properties

    var switcheStates:[String:[Bool]]!
//    {
//        didSet(oldVal){
//            for instrument in Instrument.cases{
//                guard let switches = switcheStates[instrument] else { return }
//                guard let players = mixedAudioPlayers[instrument] else {return}
//                reflect(switchesStates: switches, to: players)
//            }
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        mixedAudioPlayers = initializeDic(of: AVPlayer.self, with: Instrument.cases)
//        mixedAudioLocalURLs = initializeDic(of: URL.self, with: Instrument.cases)
//        switcheStates = initializeDic(of: Bool.self, with: Instrument.cases)

        detailTV.delegate = self
        detailTV.dataSource = self
        
        masterAudioRemoteURL = URL(string: post.author_track.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)!, relativeTo: NetworkController.main.baseMediaURL)

        let commentTracks = post.comment_tracks
//        for instrument in commentTracks.keys{
//            currentInstrument = instrument
//            for track in commentTracks[instrument]!{
//                NetworkController.main.downloadAudio( from: track.comment_track.url, done: { (localURL) in
//                    self.mixedAudioLocalURLs[instrument]!.append(localURL)
//                })
//                switcheStates[instrument]!.append(false)
//            }
//        }
    }
}

// MARK: AudioCommentDelegate
extension DetailViewController:AudioCommentCellDelegate{
    func didSwitchToggled(to state: Bool, by tag: Int, of instrument: String) {
        if switcheStates[instrument] != nil {
            switcheStates[instrument]![tag] = state
        }
    }
}

extension DetailViewController:ModeToggleCellDelegate{
    func didModeToggled(to mode: Bool) {
        toggleMode()
        toggleSwitches(to: mode)

    }
    private func toggleMode(){
        if playMode == .master { playMode = .mixed }
        else { playMode = .master }
    }
    private func toggleSwitches(section:Int, to mode:Bool){
        guard let instrument = getInstrument(at: section) else {return}
        guard let comments = post.comment_tracks[instrument] else {return}
        for i in 0..<comments.count{
            let indexPath = IndexPath(item: i, section: section)
            if let commentCell = detailTV.cellForRow(at: indexPath) as? AudioCommentCell{
                commentCell.toggleSwitch.setOn(mode, animated: true)
                switcheStates[instrument]![i] = mode
            }
        }
    }
    private func toggleSwitches(to mode:Bool){
        for i in 0..<Instrument.cases.count{
            toggleSwitches(section: i + SectionRange.MixedTracks.range.lowerBound, to: mode)
        }
    }
}

// MARK: TableView Delegate
extension DetailViewController: UITableViewDataSource, UITableViewDelegate{
    /// Master / MixedHeader/ Mixed / CommentHeader / Comment
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if SectionRange.MixedTracks.range.contains(section){
//            let headerTitle = Instrument.cases[section - SectionRange.MixedTracks.range.lowerBound]
//            if post.comment_tracks[headerTitle] == nil { return nil }
//            return UIView.generateHeaderView(with: headerTitle)
//        }
//        return nil
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if SectionRange.MixedTracks.range.contains(section) {
//            if let comments = post.comment_tracks[Instrument.cases[section-2]]{
//                if comments.count > 0 { return 100 }
//            }
//        }
//        return 0.1
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 0 && indexPath.item == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "detailHeaderCell", for: indexPath) as! DetailHeaderCell
            cell.postInfo = self.post
            return cell
        }else if indexPath.section == 0 && indexPath.item == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "masterWaveCell", for: indexPath)
            return cell.becomeMasterWaveCell(with: masterAudioRemoteURL, completion: { (localURL) in
                self.masterPlayer = AVPlayer(url: localURL)
                DispatchQueue.main.async(execute: { self.playButton.isEnabled = true })
            })
        }
        else if SectionRange.MixedTrackHeader.range.contains(indexPath.section) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MixedCommentHeaderCell", for: indexPath) as! ModeToggleCell
            cell.delegate = self
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "MixedTracksContainer", for: indexPath) as! MixedTracksContainerCell
            
            cell.allComments = post.comment_tracks
            cell.commentTV.reloadData()
            mixedCommentsContainer = cell
            return cell
        }
        
//        else if SectionRange.MixedTrackHeader.range.contains(indexPath.section) {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "MixedCommentHeaderCell", for: indexPath) as! ModeToggleCell
//            cell.delegate = self
//            return cell
//        }else if SectionRange.MixedTracks.range.contains(indexPath.section) {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "mixedTrackCell", for: indexPath)
//            let comments = post.comment_tracks[Instrument.cases[indexPath.section-2]]!
//            cell.tag = indexPath.item
//            return cell.becomeAudioCommentCell(with comment: comments[indexPath.item], delegate: self)
//        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 { return 200 }
        else if indexPath.section == 1 { return 60 }
        else {
            return CGFloat(post.num_comments * 100)
        }
    }
}

// MARK: Helper Functions
extension DetailViewController{

    
    private func reflect(switchesStates:[Bool], to players:[AVPlayer]){
        for i in 0..<switchesStates.count{
            if switchesStates[i] == false { players[i].volume = 0 }
            else { players[i].volume = 1 }
        }
    }
    
    private func getInstrument(at section:Int)->String?{
        if SectionRange.MixedTracks.range.contains(section){
            return Instrument.cases[section - SectionRange.MixedTracks.range.lowerBound]
        }
        return nil
    }
}
// MARK: Play and Pause Functions
//extension DetailViewController{
//    private func playMusic(){
//        switch playMode {
//        case .master:
//            for instrument in Instrument.cases{
//                guard let switches = switcheStates[instrument] else { return }
//                guard let players = mixedAudioPlayers[instrument] else {return}
//                reflect(switchesStates: switches, to: players)
//            }
//            masterPlayer.volume = 1
//            masterPlayer.play()
//        case .mixed:
//            masterPlayer.volume = 0
//            for instrument in Instrument.cases{
//                play(instrument)
//            }
//        }
//    }
//
//    private func play(_ instrument:String){
//        guard let playlist = mixedAudioPlayers[instrument] else {return}
//        play(list: playlist)
//    }
//
//    private func play(list:[AVPlayer]){
//        for item in list{
//            item.play()
//        }
//    }
//
//    private func pauseMusic(){
//        switch playMode {
//        case .master:
//            masterPlayer.pause()
//        case .mixed:
//            for instrument in Instrument.cases{
//                pause(instrument)
//            }
//        }
//    }
//
//    private func pause(_ instrument:String){
//        guard let playlist = mixedAudioPlayers[instrument] else {return}
//        pause(list: playlist)
//    }
//
//    private func pause(list:[AVPlayer]){
//        for item in list{
//            item.pause()
//        }
//    }
//}

// MARK: Helper Enums
extension DetailViewController{
    private enum SectionRange:Int{
        case MainHeader
        case MixedTrackHeader
        case MixedTracks
        case commentTrackHeader

        var range:CountableClosedRange<Int>{
            switch self{
            case .MainHeader:
                return 0 ... 0
            case .MixedTrackHeader:
                return 1 ... 1
            case .MixedTracks:
                return 2...(2 + Instrument.cases.count - 1)
            case .commentTrackHeader:
                return (2 + Instrument.cases.count)...(2 + Instrument.cases.count)
            }
        }
    }

    private enum Phase{
        case Ready
        case Playing
        case Recording
    }
}


