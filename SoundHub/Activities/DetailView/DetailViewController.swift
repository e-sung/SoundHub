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
            for player in audioPlayers {player.play()}
        }else if currentPhase == .Playing{
            sender.setImage(#imageLiteral(resourceName: "ic_play_circle_outline_white"), for: .normal)
            currentPhase = .ReadyToPlay
            for player in audioPlayers {player.pause()}
        }
    }
    
    // MARK: Stored Properties
    var post:Post!
    var masterWaveCell:MasterWaveFormViewCell!
    var masterAudioRemoteURL:URL!
    var mixedAudioRemoteURLs:[URL] = []
    fileprivate var currentPhase = Phase.ReadyToPlay
    var audioPlayers:[AVPlayer] = []
    var masterAudioLocalURL:URL?

    // MARK: Obserable Properties
    var mixedAudioLocalURLs:[URL] = []{
        didSet(oldVal){
            audioPlayers.append(AVPlayer(url: mixedAudioLocalURLs.last!))
            if audioPlayers.count == mixedAudioLocalURLs.count {
                playButton.isEnabled = true
            }
        }
    }
    var switcheStates:[Bool] = []{
        didSet(oldVal){
            for i in 0..<switcheStates.count{
                if switcheStates[i] == false { audioPlayers[i].volume = 0 }
                else { audioPlayers[i].volume = 1 }
            }
        }
    }
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        masterAudioRemoteURL = URL(string: post.author_track!, relativeTo: NetworkController.main.baseMediaURL)
//        for comment in post.comment_tracks{
//            mixedAudioLocalURLs.append(URL(string: comment.comment_track)!)
//        }
        
        for url in mixedAudioRemoteURLs{
            NetworkController.main.downloadAudio(from: url, done: { (localURL) in
                self.mixedAudioLocalURLs.append(localURL)
            })
        }
        detailTV.delegate = self
        detailTV.dataSource = self
//        for _ in post.comment_tracks{
//            switcheStates.append(true)
//        }
    }
}

// MARK: AudioCommentDelegate
extension DetailViewController:AudioCommentCellDelegate{
    func didSwitchToggled(state: Bool, by tag: Int) {
        switcheStates[tag] = state
    }
}

// MARK: TableView Delegate
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
//            return post.comment_tracks.count
        case .CommentTracks:
            return 2
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
        }else if Section(rawValue: indexPath.section) == .MixedTracks{
            let cell =  tableView.dequeueReusableCell(withIdentifier: "mixedTrackCell", for: indexPath)
            return generateAudioCommentCell(outof: cell, on: indexPath)
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentTrackCell", for: indexPath)
            return generateAudioCommentCell(outof: cell, on: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section>0 ? 100 : 200
    }
}

// MARK: Helper Functions
extension DetailViewController{
    private func generateAudioCommentCell(outof cell:UITableViewCell, on indexPath:IndexPath)->AudioCommentCell{
        let commentCell = cell as! AudioCommentCell
        commentCell.tag = indexPath.item
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
