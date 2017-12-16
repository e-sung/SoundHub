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
    
    // MARK: Internal Stored Properties
    /// 이 디테일뷰에서 표시해야 할 Post객체
    var post:Post!
    /// 현재 뭐하는 중인지 (대기중/재생중/녹음중)
    var currentPhase:PlayPhase = .Ready
    // MARK: Private Stored Properties
    /// 음악 파형이 표시되는 셀
    private var masterWaveCell:MasterWaveFormViewCell?
    /// 녹음하는 셀
    private var recorderCell: RecorderCell?
    /// Master Track을 재생하는 플레이어
    private var masterAudioPlayer:AVPlayer?{
        didSet(oldVal){
            if let timeObserver = AVPlayerTimeObserver { oldVal?.removeTimeObserver(timeObserver) }
            guard let masterAudioPlayer = masterAudioPlayer else { return }
            let cmt = CMTime(value: 1, timescale: 10)
            AVPlayerTimeObserver = masterAudioPlayer.addPeriodicTimeObserver(forInterval: cmt, queue: DispatchQueue.main, using: { (cmt) in
                if masterAudioPlayer.isPlaying {
                    PlayBarController.main.reflect(progress: masterAudioPlayer.progress)
                }
            })
        }
    }
    /**
     mixedTrack들을 담고있는 셀. Playable 프로토콜을 상속받았다.
     따라서 **mixedTrackContainer.play()** 같은 것들이 가능하다.
    */
    private var mixedTrackContainer:MixedTracksContainerCell?
    private var allAudioPlayers:[Playable?]{
        return [ masterAudioPlayer, mixedTrackContainer ]
    }
    /// 마스터, 혹은 mixedTrackContainer 등이 번갈아가면서 mainAudioPlayer가 된다.
    /// 이전의 mainAUdioPlayer는 뮤트된다.
    private var mainAudioPlayer:Playable?{
        didSet(oldVal){
            oldVal?.setMute(to: true)
            mainAudioPlayer?.setMute(to: false)
        }
    }
    /// 원저작자에게만 보이는, "머지"하기 위해 multiselection을 통해 고른 셀들에 담겨있는 Comment 정보
    private var selectedComments:[Comment]?

    // MARK: IBOutlets
    @IBOutlet weak private var playBarView: UIView!
    @IBOutlet weak private var detailTV: UITableView!

    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        detailTV.delegate = self
        detailTV.dataSource = self
        if let materRemoteURL = post.authorTrackRemoteURL{ masterAudioPlayer = AVPlayer(url: materRemoteURL) }
        mainAudioPlayer = masterAudioPlayer
        PlayBarController.main.view.isHidden = false
    }
    override func viewWillAppear(_ animated: Bool) {
        PlayBarController.main.currentPostView = self
    }
    override func viewDidAppear(_ animated: Bool) {
        masterWaveCell?.renderWave()
    }
    override func viewWillDisappear(_ animated: Bool) {
        recorderCell?.deinitialize()
    }
}

// MARK: 모드가 변경되었을 때 처리
extension DetailViewController:ModeToggleCellDelegate{
    func didModeToggled(to mode: Bool) {
        if mode == true {
            mainAudioPlayer = mixedTrackContainer
            masterAudioPlayer?.setMute(to: true)
        }
        else {
            mainAudioPlayer = masterAudioPlayer
            mixedTrackContainer?.setMute(to: true)
        }
        mixedTrackContainer?.setInteractionability(to: mode)
    }
}

extension DetailViewController:Playable{
    func reflect(progress:Float){
        self.masterWaveCell?.reflect(progress: progress)
    }
    
    func stop(){
        currentPhase = .Ready
        for player in allAudioPlayers { player?.stop() }
    }
    
    func play(){
        currentPhase = .Playing
        for player in allAudioPlayers { player?.play() }
    }
    
    func pause(){
        currentPhase = .Ready
        for player in allAudioPlayers { player?.pause() }
    }
    
    func seek(to point:Float){
        for player in allAudioPlayers { player?.seek(to: point) }
        reflect(progress: point)
    }
    func setVolume(to value: Float) {
        for player in allAudioPlayers { player?.setVolume(to: value) }
    }
    
    func setMute(to value: Bool) {
        for player in allAudioPlayers { player?.setMute(to: value) }
    }
}


extension DetailViewController:MixedTracksContainerCellDelegate{
    func didSelectionOccured(on comments: [Comment]) {
        if comments.count == 0 {
            navigationItem.setRightBarButton(nil, animated: true)
            return
        }
        selectedComments = comments
        let mergeButton = UIBarButtonItem(title: "Merge", style: .plain, target: self, action: #selector(merge))
        navigationItem.setRightBarButton(mergeButton, animated: true)
    }
    @objc private func merge(){
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
            masterWaveCell = cell.becomeMasterWaveCell(with: post.authorTrackRemoteURL, completion: { (localURL) in
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
    
    /**
     특정 post를 보여주는 DetailViewController로 이동하는 함수
     - parameter post : 도착한 DetailVC가 보여줘야 할 post 정보
     - parameter vc : 출발하는 ViewController 
    */
    static func goToDetailPage(of post:Post, from vc:UIViewController){
        /// 보려는 포스트가, 현재 플레이바에서 재생중인 포스트라면
        if post.title == PlayBarController.main.currentPostView?.post.title {
            /// 그 포스트객체는 PlayBarController.main에 저장되어 있으니, 그걸 보여주면 됨.
            vc.navigationController?.show(PlayBarController.main.currentPostView!, sender: nil)
        }
        
        /// 그게 아니라면, 프로필 페이지에 있는 Post객체는 제한된 정보만 가지고 있기 때문에,
        /// 온전한 Post객체를 다시 서버에서 받아와야 함.
        NetworkController.main.fetchPost(id: post.id) { (fetchedPost) in
            let nextVC = UIStoryboard(name: "Detail", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            nextVC.post = fetchedPost
            DispatchQueue.main.async { vc.navigationController?.show(nextVC, sender: nil) }
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

protocol Playable {
    func play()
    func pause()
    func stop()
    func seek(to point:Float)
    func setVolume(to value:Float)
    func setMute(to value:Bool)
}
