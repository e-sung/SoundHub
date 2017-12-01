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
    var post:Post!
    @IBOutlet weak var detailTV: UITableView!
    @IBOutlet weak var playButton: UIButton!
    @IBAction func playButtonHandler(_ sender: UIButton) {
        if currentPhase == .ReadyToPlay {
            sender.setImage(#imageLiteral(resourceName: "ic_pause_circle_outline_white"), for: .normal)
            currentPhase = .Playing
            for player in audioPlayers {player.play()}
        }else if currentPhase == .Playing{
            sender.setImage(#imageLiteral(resourceName: "ic_play_circle_outline_white"), for: .normal)
            currentPhase = .ReadyToPlay
            for player in audioPlayers {player.pause()}
        }
    }
    
    let masterAudioRemoteURL = URL(string: "https://s3.ap-northeast-2.amazonaws.com/che1-soundhub/media/author_tracks/guitar.m4a")!
    let mixedAudioRemoteURLs = [
        URL(string: "https://s3.ap-northeast-2.amazonaws.com/che1-soundhub/media/author_tracks/guitar.m4a")!,
        URL(string: "https://s3.ap-northeast-2.amazonaws.com/che1-soundhub/media/author_tracks/drum.m4a")!
    ]
    var mixedAudioLocalURLs:[URL] = []{
        didSet(oldVal){
            audioPlayers.append(AVPlayer(url: mixedAudioLocalURLs.last!))
            if audioPlayers.count == mixedAudioLocalURLs.count {
                playButton.isEnabled = true
            }
        }
    }
    var masterAudioLocalURL:URL?{
        didSet(oldVal){
            masterWaveCell.masterAudioURL = masterAudioLocalURL!
        }
    }
    
    var masterWaveCell:MasterWaveFormViewCell!
    var switcheStates:[Bool] = []{
        didSet(oldVal){
            for i in 0..<switcheStates.count{
                if switcheStates[i] == false {
                    audioPlayers[i].volume = 0
                }else{
                    audioPlayers[i].volume = 1
                }
            }
        }
    }
    var audioPlayers:[AVPlayer] = []
    
    fileprivate var currentPhase = Phase.ReadyToPlay

    override func viewDidLoad() {
        super.viewDidLoad()
        for url in mixedAudioRemoteURLs{
            NetworkController.main.downloadAudio(from: url, done: { (localURL) in
                self.mixedAudioLocalURLs.append(localURL)
            })
        }
        for _ in mixedAudioRemoteURLs {switcheStates.append(true)}
        detailTV.delegate = self
        detailTV.dataSource = self
    }
}

extension DetailViewController:AudioCommentCellDelegate{
    func didSwitchToggled(state: Bool, by tag: Int) {
        switcheStates[tag] = state
    }
}

extension DetailViewController: UITableViewDataSource, UITableViewDelegate{
    /// Master / Mixed / Comment
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100))
        header.backgroundColor = .white
        let titleLabel = UILabel(frame: header.frame)
        titleLabel.text = section == 1 ? "Mixed Tracks" : "Comment Tracks"
        titleLabel.font = titleLabel.font.withSize(30)
        header.addSubview(titleLabel)
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section > 0 ? 100 : 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .Header:
            return 2
        case .MixedTracks:
            return 2
        case .CommentTracks:
            return post.comment_tracks.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 && indexPath.item == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "detailHeaderCell", for: indexPath) as! DetailHeaderCell
            cell.postInfo = self.post
            return cell
        }else if indexPath.section == 0 && indexPath.item == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "masterWaveCell", for: indexPath) as! MasterWaveFormViewCell
            masterWaveCell = cell
            NetworkController.main.downloadAudio(from: masterAudioRemoteURL, done: { (localURL) in
                self.masterAudioLocalURL = localURL
            })
            return cell
        }else if Section(rawValue: indexPath.section) == .MixedTracks{
            let cell =  tableView.dequeueReusableCell(withIdentifier: "mixedTrackCell", for: indexPath) as! AudioCommentCell
            cell.tag = indexPath.item
            cell.delegate = self
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentTrackCell", for: indexPath) as! AudioCommentCell
            cell.tag = indexPath.item
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section>0 ? 100 : 200
    }
}

fileprivate enum Section:Int{
    case Header = 0
    case MixedTracks = 1
    case CommentTracks = 2
}

fileprivate enum Phase{
    case ReadyToPlay
    case Playing
}
