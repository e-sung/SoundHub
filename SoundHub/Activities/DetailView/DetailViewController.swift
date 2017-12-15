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
import NCSoundHistogram

class DetailViewController: UIViewController{
    
    // MARK: Stored Properties
    var post:Post!
    var playBarController:PlayBarController!
    var masterWaveCell:MasterWaveFormViewCell?
    var mixedTrackContainer:MixedTracksContainerCell!
    var recorderCell: RecorderCell?
    var presentedByPlayBar = false
    var currentPhase:PlayPhase = .Ready
    var currentPlayMode:PlayMode = .master
    var mainAudioPlayer:AVPlayer?{
        didSet(oldVal){
            if let timeObserver = AVPlayerTimeObserver { oldVal?.removeTimeObserver(timeObserver) }
            let cmt = CMTime(value: 1, timescale: 10)
            AVPlayerTimeObserver = mainAudioPlayer?.addPeriodicTimeObserver(forInterval: cmt, queue: DispatchQueue.main, using: {
                (cmt) in
                if self.mainAudioPlayer!.isPlaying == true {
                    let progress = Float(self.mainAudioPlayer!.currentTime().seconds/self.mainAudioPlayer!.currentItem!.duration.seconds)
                    PlayBarController.main.reflect(progress: progress)
                }
            })
        }
    }
    var masterAudioRemoteURL:URL!
    var masterAudioPlayer:AVPlayer?{
        didSet(oldVal){
            
        }
    }
    var currentSelectedComments:[Comment]?
    @objc func cancelButtonHandler(sender:UIBarButtonItem){
        self.dismiss(animated: true, completion: {
            self.navigationItem.setRightBarButton(nil, animated: false)
        })
    }

    // MARK: IBOutlets
    
    @IBOutlet weak var playBarView: UIView!
    @IBOutlet weak var detailTV: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        detailTV.delegate = self
        detailTV.dataSource = self
        masterAudioRemoteURL = URL(string: post.author_track!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)!, relativeTo: NetworkController.main.baseMediaURL)
        masterAudioPlayer = AVPlayer(url: masterAudioRemoteURL)
        mainAudioPlayer = masterAudioPlayer
        playBarController = PlayBarController.main
        playBarController.view.isHidden = false
    }
    override func viewWillAppear(_ animated: Bool) {
        playBarController.currentPostView = self
    }
    override func viewDidAppear(_ animated: Bool) {
        masterWaveCell?.renderWave()
    }
    override func viewWillDisappear(_ animated: Bool) {
        recorderCell?.deinitialize()
    }
}

extension DetailViewController:ModeToggleCellDelegate{
    func didModeToggled(to mode: Bool) {
//        playBarController.stopMusic()
        if mode == true {
            currentPlayMode = .mixed
            mixedTrackContainer.setVolume(to: 1)
            mainAudioPlayer?.volume = 0
        } else {
            currentPlayMode = .master
            mixedTrackContainer.setVolume(to: 0)
            mainAudioPlayer?.volume = 1
        }
        mixedTrackContainer.setInteractionability(to: mode)
    }
}

extension DetailViewController{
    func reflect(progress:Float){
        self.masterWaveCell?.reflect(progress: progress)
    }
    
    func stopMusic(){
        currentPhase = .Ready
        mainAudioPlayer?.stop()
        mixedTrackContainer?.stopMusic()
        
    }
    
    func playMusic(){
        currentPhase = .Playing
        mainAudioPlayer?.play()
        mixedTrackContainer.playMusic()
    }
    
    func pauseMusic(){
        currentPhase = .Ready
        mainAudioPlayer?.pause()
        mixedTrackContainer?.pauseMusic()
    }
    
    func seek(to point:Float){
        mainAudioPlayer?.seek(to: point)
        mixedTrackContainer.seek(to: point)
        reflect(progress: point)
    }
}


extension DetailViewController:MixedTracksContainerCellDelegate{
    func didSelectionOccured(on comments: [Comment]) {
        if comments.count == 0 {
            navigationItem.setRightBarButton(nil, animated: true)
            return
        }
        currentSelectedComments = comments
        let mergeButton = UIBarButtonItem(title: "Merge", style: .plain, target: self, action: #selector(merge))
        navigationItem.setRightBarButton(mergeButton, animated: true)
    }
    @objc func merge(){
        alert(msg: "Merge!")
    }
}

// MARK: TableView Delegate
extension DetailViewController: UITableViewDataSource, UITableViewDelegate{
    /// Master / MixedHeader/ Mixed / CommentHeader / Comment
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue:section)!{
        case .MainHeader:
            return 2
        case .MixedTrackToggler:
            return 1
        case .MixedTracks:
            return 1
        case .RecordCell:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 0 && indexPath.item == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "detailHeaderCell", for: indexPath) as! DetailHeaderCell
            cell.postInfo = self.post
            return cell
        }else if indexPath.section == 0 && indexPath.item == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "masterWaveCell", for: indexPath)
            masterWaveCell = cell.becomeMasterWaveCell(with: masterAudioRemoteURL, completion: { (localURL) in
                self.masterAudioPlayer = AVPlayer(url: localURL)
            })
            return masterWaveCell!
        }
        else if Section(rawValue: indexPath.section) == .MixedTrackToggler {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MixedCommentHeaderCell", for: indexPath) as! ModeToggleCell
            cell.delegate = self
            return cell
        }
        else if Section(rawValue: indexPath.section) == .MixedTracks {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MixedTracksContainer", for: indexPath) as! MixedTracksContainerCell
            cell.allComments = post.comment_tracks
            cell.delegate = self
            if DataCenter.main.userNickName == post.author {
                cell.commentTV.allowsMultipleSelection = true
            }
            mixedTrackContainer = cell
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "recorderCell", for: indexPath) as! RecorderCell
            cell.delegate = self
            recorderCell = cell
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if Section(rawValue:indexPath.section) == .MainHeader { return 200 }
        else if Section(rawValue:indexPath.section) == .MixedTrackToggler { return 60 }
        else if Section(rawValue:indexPath.section) == .MixedTracks {
            return CGFloat(post.num_comments! * 100)
        }else {
            return 100
        }
    }
}

// MARK: Helper Enums
extension DetailViewController{
    private enum Section:Int{
        case MainHeader = 0
        case MixedTrackToggler = 1
        case MixedTracks = 2
        case CommentTrackToggler = 3
        case CommentTracks = 4
        case RecordCell = 5
    }

    enum PlayPhase{
        case Ready
        case Playing
        case Recording
    }
    enum PlayMode{
        case master
        case mixed
    }
}
