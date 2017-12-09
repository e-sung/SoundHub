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

    var masterPlayer:AVPlayer!
    private var playMode:PlayMode = .master
    
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
            playMusic()
        }else if currentPhase == .Playing{
            pauseMusic()
        }
    }
    
    func playMusic(){
        playButton.setImage(#imageLiteral(resourceName: "ic_pause_circle_outline_white"), for: .normal)
        currentPhase = .Playing
        if playMode == .mixed { mixedCommentsContainer.playMusic() }
        else { masterPlayer.play() }
    }
    
    func pauseMusic(){
        playButton.setImage(#imageLiteral(resourceName: "ic_play_circle_outline_white"), for: .normal)
        currentPhase = .Ready
        if playMode == .mixed{ mixedCommentsContainer.pauseMusic() }
        else{ masterPlayer.pause() }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        detailTV.delegate = self
        detailTV.dataSource = self
        
        masterAudioRemoteURL = URL(string: post.author_track.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)!, relativeTo: NetworkController.main.baseMediaURL)
    }
}

extension DetailViewController:ModeToggleCellDelegate{
    func didModeToggled(to mode: Bool) {
        pauseMusic()
        if mode == true { playMode = .mixed} else { playMode = .master}
        mixedCommentsContainer.setInteractionability(to: mode)
    }
}

// MARK: TableView Delegate
extension DetailViewController: UITableViewDataSource, UITableViewDelegate{
    /// Master / MixedHeader/ Mixed / CommentHeader / Comment
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

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
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 { return 200 }
        else if indexPath.section == 1 { return 60 }
        else {
            return CGFloat(post.num_comments * 100)
        }
    }
}

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


