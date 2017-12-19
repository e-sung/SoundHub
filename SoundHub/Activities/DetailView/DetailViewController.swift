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
import ActionSheetPicker_3_0

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
    private var authorTrackPlayer:AVPlayer?
    /**
     mixedTrack들을 담고있는 셀. Playable 프로토콜을 상속받았다.
     따라서 **mixedTrackContainer.play()** 같은 것들이 가능하다.
    */
    private var mixedTrackContainer:CommentContainerCell?
    /**
     commentTrack들을 담고있는 셀. Playable 프로토콜을 상속받았다.
     따라서 **commentTrackContainer.play()** 같은 것들이 가능하다.
     */
    private var commentTrackContainer:CommentContainerCell?
    private var allAudioPlayers:[Playable?]{
        return [ masterAudioPlayer, authorTrackPlayer, mixedTrackContainer, commentTrackContainer]
    }
    
    /// 원저작자에게만 보이는, "머지"하기 위해 multiselection을 통해 고른 셀들에 담겨있는 Comment 정보
    private var selectedComments:[Comment]?

    // MARK: IBOutlets
    /// 이 VC의 최상단 테이블뷰
    @IBOutlet weak private var mainTV: UITableView!
    @IBAction func unwindToDetailView(segue:UIStoryboardSegue) {
        self.commentTrackContainer?.isNewTrackBeingAdded = true
        self.mainTV.reloadData()
    }
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        mainTV.delegate = self
        mainTV.dataSource = self
        if let materRemoteURL = post.masterTrackRemoteURL{
            masterAudioPlayer = AVPlayer(url: materRemoteURL)
            PlayBarController.main.view.isHidden = false
        }
        if let authorTrackURL = post.authorTrackRemoteURL{
            authorTrackPlayer = AVPlayer(url:authorTrackURL)
            NetworkController.main.downloadAudio(from: authorTrackURL, completion: { (localURL) in
                self.authorTrackPlayer = AVPlayer(url:localURL)
            })
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        PlayBarController.main.currentPostView = self
    }
    override func viewDidAppear(_ animated: Bool) {
        masterWaveCell?.renderWave()
        if post.author == UserDefaults.standard.string(forKey: nickname){
            commentTrackContainer?.allowsMultiSelection = true
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        recorderCell?.deinitialize()
    }
}

// MARK: 모드가 변경되었을 때 처리
extension DetailViewController:ModeToggleCellDelegate{
    func didModeToggled(to mode: Bool, by toggler: Int) {
        if toggler == 0 {
            mixedTrackContainer?.setMute(to: !mode)
            mixedTrackContainer?.setInteractionability(to: mode)
        }
        if toggler == 1 {
            commentTrackContainer?.setMute(to: !mode)
            commentTrackContainer?.setInteractionability(to: mode)
        }
        guard let mixed = mixedTrackContainer, let comment = commentTrackContainer else { return }
        if mixed.isMuted == true && comment.isMuted == true{
            authorTrackPlayer?.isMuted = true
            masterAudioPlayer?.isMuted = false
        }else{
            authorTrackPlayer?.isMuted = false
            masterAudioPlayer?.isMuted = true
        }
    }
}

// MARK: Playable 프로토콜 구현
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

// MARK: MixedTracksContainerCellDelegate
extension DetailViewController:MixedTracksContainerCellDelegate{
    func didSelectionOccured(on comments: [Comment]) {
        if comments.count == 0 { navigationItem.setRightBarButton(nil, animated: true); return }
        selectedComments = comments
        navigationItem.setRightBarButton(
            UIBarButtonItem(title: "Merge", style: .plain, target: self, action: #selector(mix)),
            animated: true)
    }
    @objc private func mix(){
        guard let selectedComments = selectedComments else { return }
        var comments:[Int] = []
        for comment in selectedComments{
            guard let commentId = comment.id else {
                self.mixedTrackContainer?.allowsMultiSelection = false
                self.navigationItem.setRightBarButton(nil, animated: true)
                return
            }
            comments.append(commentId)
        }
        guard let postId = post.id else { return }
        NetworkController.main.mix(comments: comments, on: postId, completion: {
            NetworkController.main.fetchPost(id: postId, completion: { (post) in
                self.post = post
                DispatchQueue.main.async {
                    self.mixedTrackContainer?.isNewTrackBeingAdded = true
                    let ids = IndexSet(integersIn: Section.MixedTracks.rawValue ... Section.MixedTracks.rawValue)
                    self.mainTV.reloadSections(ids, with: .automatic)
                    self.mixedTrackContainer?.allowsMultiSelection = false
                    self.navigationItem.setRightBarButton(nil, animated: true)
                }
            })
        })
    }
}

// MARK:RecorderCellDelegate
extension DetailViewController:RecorderCellDelegate{
    func uploadDidFinished(with post: Post?) {
        guard let post = post else { return }
        self.post = post
        mainTV.reloadData()
    }
    
    func shouldShowAlert() {
        let alert = UIAlertController(title: "녹음 업로드", message: "녹음을 업로드 하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .cancel , handler: { (action) in
            self.showInstrumentPicker()
        }))
        alert.addAction(UIAlertAction(title: "취소", style: .destructive, handler: { (action) in
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func showInstrumentPicker(){
        ActionSheetStringPicker.show(withTitle: "어떤 악기였나요?", rows: Instrument.cases, initialSelection: 0, doneBlock: { (picker, row, result) in
                let selectedInstrument = Instrument.cases[row]
            guard let postId = self.post.id else { return }
            RecordConductor.main.confirmComment(on: postId, of: selectedInstrument, completion: { (postResult) in
                guard let postResult = postResult else { return }
                self.post = postResult
                self.commentTrackContainer?.isNewTrackBeingAdded = true
                let ids = IndexSet(integersIn: Section.CommentTracks.rawValue ... Section.CommentTracks.rawValue)
                self.mainTV.reloadSections(ids, with: .automatic)
            })
        }, cancel: { (picker) in
        }, origin: self.view)
    }
}

// MARK: TableView Delegate
extension DetailViewController: UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int { return Section.cases }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Section(rawValue:section)!.rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(indexPath.section)
        if indexPath.section == 0 && indexPath.item == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "detailHeaderCell", for: indexPath) as! DetailHeaderCell
            cell.postInfo = self.post
            return cell
        }else if indexPath.section == 0 && indexPath.item == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "masterWaveCell", for: indexPath)
            masterWaveCell = cell.becomeMasterWaveCell(with: post.masterTrackRemoteURL, completion: { (localURL) in
                if self.masterAudioPlayer == nil {
                    self.masterAudioPlayer = AVPlayer(url: localURL)
                }
            })
            return masterWaveCell!
        }
        else if Section(rawValue: indexPath.section) == .MixedTrackToggler {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MixedCommentHeaderCell", for: indexPath) as! ModeToggleCell
            cell.delegate = self
            return cell
        }else if Section(rawValue: indexPath.section) == .MixedTrackToggler {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTracksHeaderCell", for: indexPath) as! ModeToggleCell
            cell.delegate = self
            return cell
        }else if Section(rawValue: indexPath.section) == .MixedTracks {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MixedTracksContainer", for: indexPath) as! CommentContainerCell
            cell.allComments = post.mixed_tracks
            cell.delegate = self
            mixedTrackContainer = cell
            return cell
        }else if Section(rawValue: indexPath.section) == .CommentTrackToggler{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTracksHeaderCell", for: indexPath) as! ModeToggleCell
            cell.delegate = self
            return cell
        }else if Section(rawValue: indexPath.section) == .CommentTracks {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTracksContainer", for: indexPath) as! CommentContainerCell
            cell.allComments = post.comment_tracks; cell.delegate = self
            if DataCenter.main.userNickName == post.author{
                cell.commentTV.allowsMultipleSelection = true
            }
            commentTrackContainer = cell
            return cell
        }
        else if Section(rawValue: indexPath.section) == .RecordCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "recorderCell", for: indexPath) as! RecorderCell
            cell.delegate = self
            recorderCell = cell
            return cell
        }else{
           return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if Section(rawValue:indexPath.section) == .MainHeader { return 200 }
        else if Section(rawValue:indexPath.section) == .MixedTrackToggler { return 60 }
        else if Section(rawValue:indexPath.section) == .CommentTrackToggler { return 60 }
        else if Section(rawValue:indexPath.section) == .MixedTracks {
            return CGFloat(post.numOfMixedTracks * 100)
        }else if Section(rawValue:indexPath.section) == .CommentTracks{
            return CGFloat(post.numOfCommentTracks * 100)
        }
        return 100
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
        }else{
            /// 그게 아니라면, 프로필 페이지에 있는 Post객체는 제한된 정보만 가지고 있기 때문에,
            /// 온전한 Post객체를 다시 서버에서 받아와야 함.
            guard let postId = post.id else { return }
            NetworkController.main.fetchPost(id: postId) { (fetchedPost) in
                let nextVC = UIStoryboard(name: "Detail", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
                nextVC.post = fetchedPost
                DispatchQueue.main.async { vc.navigationController?.show(nextVC, sender: nil) }
            }
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
        /**
         모든 Section의 경우의 수
         
         MainHeader/ MasterWave / MixedHeader/ Mixed / CommentHeader / Comment
        */
        static var cases:Int{get{return 6}}
        var rows:Int{
            get{
                switch self {
                case .MainHeader: return 2
                default:
                    return 1
                }
            }
        }
    }

    enum PlayPhase{
        case Ready
        case Playing
        case Recording
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
