//
//  DetailViewController.swift
//  soundHubPractice
//
//  Created by 류성두 on 2017. 11. 26..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit
import AVFoundation

class DetailViewController: UIViewController{
    // MARK: IBOutlets
    @IBOutlet weak private var detailTV: UITableView!
    @IBOutlet weak private var playButton: UIButton!
    
    // MARK: IBActions
    @IBAction private func playButtonHandler(_ sender: UIButton) {
        if currentPhase == .ReadyToPlay {
            sender.setImage(#imageLiteral(resourceName: "ic_pause_circle_outline_white"), for: .normal)
            currentPhase = .Playing
            for instrument in Instrument.cases{
                if let players = audioPlayers[instrument]{
                    for player in players{
                        player.play()
                    }
                }
            }
        }else if currentPhase == .Playing{
            sender.setImage(#imageLiteral(resourceName: "ic_play_circle_outline_white"), for: .normal)
            currentPhase = .ReadyToPlay
            for instrument in Instrument.cases{
                if let players = audioPlayers[instrument]{
                    for player in players{
                        player.pause()
                    }
                }
            }
        }
    }
    
    // MARK: Stored Properties
    var post:Post!
    var masterWaveCell:MasterWaveFormViewCell!
    var masterAudioRemoteURL:URL!
    fileprivate var currentPhase = Phase.ReadyToPlay
    var currentInstrument:String?
    var audioPlayers:[String:[AVPlayer]]!
    
    // MARK: Obserable Properties
    var mixedAudioLocalURLs:[String:[URL]]!{
        didSet(oldVal){
            guard let currentInstrument = currentInstrument else { return }
            if audioPlayers[currentInstrument] != nil{
                audioPlayers[currentInstrument]!.append(AVPlayer(url: (mixedAudioLocalURLs[currentInstrument]?.last!)!))
            }
            /// ToDo : play button should be enabled when master track is downloaded
            playButton.isEnabled = true
        }
    }
    var switcheStates:[String:[Bool]]!{
        didSet(oldVal){
            for instrument in Instrument.cases{
                guard let switches = switcheStates[instrument] else { return }
                guard let players = audioPlayers[instrument] else {return}
                reflect(switchesStates: switches, to: players)
            }
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        audioPlayers = initializeDic(of: AVPlayer.self, with: Instrument.cases)
        mixedAudioLocalURLs = initializeDic(of: URL.self, with: Instrument.cases)
        switcheStates = initializeDic(of: Bool.self, with: Instrument.cases)

        detailTV.delegate = self
        detailTV.dataSource = self
        
        masterAudioRemoteURL = URL(string: post.author_track.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)!, relativeTo: NetworkController.main.baseMediaURL)
        
        let commentTracks = post.comment_tracks
        for instrument in commentTracks.keys{
            currentInstrument = instrument
            for track in commentTracks[currentInstrument!]!{
                NetworkController.main.downloadAudio( from: track.comment_track.url, done: { (localURL) in
                    self.mixedAudioLocalURLs[self.currentInstrument!]!.append(localURL)
                })
                switcheStates[instrument]!.append(true)
            }
        }
    }
}

// MARK: AudioCommentDelegate
extension DetailViewController:AudioCommentCellDelegate{
    func didSwitchToggled(to state: Bool, by tag: Int, of instrument: String) {
        if switcheStates[instrument] != nil {
            switcheStates[instrument]![tag] = state
            if var switches = switcheStates[instrument]{
                
                switches[tag] = state
            }
        }
    }
    
}

// MARK: TableView Delegate
extension DetailViewController: UITableViewDataSource, UITableViewDelegate{
    /// Master / Mixed / Comment
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 + Instrument.cases.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 { return nil }
        return generateHeaderCell(with: Instrument.cases[section-1])
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section > 0 ? 100 : 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }else{
            return post.comment_tracks[Instrument.cases[section - 1]]?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 0 && indexPath.item == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "detailHeaderCell", for: indexPath) as! DetailHeaderCell
            cell.postInfo = self.post
            return cell
        }else if indexPath.section == 0 && indexPath.item == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "masterWaveCell", for: indexPath)
            return generateMasterWaveCell(outof: cell)
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "mixedTrackCell", for: indexPath)
            let comments = post.comment_tracks[Instrument.cases[indexPath.section-1]]!
            cell.tag = indexPath.item
            return generateAudioCommentCell(outof: cell, and: comments[indexPath.item])
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section>0 ? 100 : 200
    }
}

// MARK: Helper Functions
extension DetailViewController{
    private func generateAudioCommentCell(outof cell:UITableViewCell, and commentInfo:Comment)->AudioCommentCell{
        let commentCell = cell as! AudioCommentCell
        commentCell.commentInfo = commentInfo
        commentCell.delegate = self
        return commentCell
    }

    private func generateMasterWaveCell(outof cell:UITableViewCell)->MasterWaveFormViewCell{
        masterWaveCell = cell as! MasterWaveFormViewCell
        NetworkController.main.downloadAudio(from: masterAudioRemoteURL, done: { (localURL) in
            self.masterWaveCell.masterAudioURL = localURL
        })
        return masterWaveCell
    }
    
    private func generateHeaderCell(with title:String)->UIView?{
        let header = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100))
        header.backgroundColor = .white
        let titleLabel = UILabel(frame: header.frame)
        titleLabel.text = title
        titleLabel.font = titleLabel.font.withSize(30)
        header.addSubview(titleLabel)
        return header
    }
    
    private func initializeDic<T>(of type: T.Type,with keys:[String])->[String:[T]]{
        var dic = [String:[T]]()
        for key in keys {
            dic[key] = []
        }
        return dic
    }
    
    private func reflect(switchesStates:[Bool], to players:[AVPlayer]){
        for i in 0..<switchesStates.count{
            if switchesStates[i] == false { players[i].volume = 0 }
            else { players[i].volume = 1 }
        }
    }
}

// MARK: Helper Enums
fileprivate enum Section:Int{
    case Header = 0
    case MixedTracks = 1
    case CommentTracks = 2
}

fileprivate enum Phase{
    case ReadyToPlay
    case Playing
}
