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
import AlamofireImage

class DetailViewController: UIViewController {

    // MARK: Internal Stored Properties
    /// 이 디테일뷰에서 표시해야 할 Post객체
    var post: Post! {
        didSet(oldVal) {
            setUpMasterPlayer()
            setUpAuthorTrackPlayer()
        }
    }
    // MARK: Private Stored Properties
    /// 음악 파형이 표시되는 셀
    private var masterWaveCell: MasterWaveFormViewCell? {
        didSet(oldVal) {
            guard let masterWaveCell = masterWaveCell else { return }
            self.render(masterWaveCell)
        }
    }

    private var mixedTrackToggler: ModeToggleCell?
    private var commentTrackToggler: ModeToggleCell?

    /// 녹음하는 셀
    private var recorderCell: RecorderCell?
    private var heightOfRecordingCell: CGFloat = 50

    /// Master Track을 재생하는 플레이어
    private var masterTrackPlayer: AVPlayer? {
        didSet(oldVal) {
            PlayBarController.main.isEnabled = true
            if let lastPlayer = oldVal { removeGlobalTimeObserver(from: lastPlayer) }
            guard let masterAudioPlayer = masterTrackPlayer else { return }
            addGlobalTimeObserver(on: masterAudioPlayer)
            NotificationCenter.default.post(name: NSNotification.Name("MasterTrackDownloaded"), object: nil)
        }
    }

    private var authorTrackPlayer: AVPlayer?
    /**
     mixedTrack들을 담고있는 셀. Playable 프로토콜을 상속받았다.
     따라서 **mixedTrackContainer.play()** 같은 것들이 가능하다.
    */
    private var mixedTrackContainer: CommentContainerCell?
    /**
     commentTrack들을 담고있는 셀. Playable 프로토콜을 상속받았다.
     따라서 **commentTrackContainer.play()** 같은 것들이 가능하다.
     */
    private var commentTrackContainer: CommentContainerCell?
    private var allAudioPlayers: [Playable?] {
        return [ masterTrackPlayer, authorTrackPlayer, mixedTrackContainer, commentTrackContainer]
    }

    /// 원저작자에게만 보이는, "머지"하기 위해 multiselection을 통해 고른 셀들에 담겨있는 Comment 정보
    private var selectedComments: [Comment]?
    private var currentTransitionCoordinator: UIViewControllerTransitionCoordinator?
    @IBOutlet weak private var albumCoverImageView: UIImageView!

    // MARK: IBOutlets
    /// 이 VC의 최상단 테이블뷰
    @IBOutlet weak private var mainTV: UITableView!

    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        mainTV.delegate = self
        mainTV.dataSource = self
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.addTarget(self, action: #selector(onPopBackHandler))
        PlayBarController.main.isHidden = false
        guard let postImageURL = post.albumCoverImageURL else { return }
        albumCoverImageView.af_setImage(withURL: postImageURL)
    }
    override func viewWillAppear(_ animated: Bool) {
        if post.mixed_tracks == nil {
            fillContainers()
        }
        PlayBarController.main.currentPostView = self
        albumCoverImageView.alpha = 1
        guard let userId = UserDefaults.standard.string(forKey: keyForUserId) else { return }
        if (post.author?.id ?? -1) == Int(userId) {
            commentTrackContainer?.allowsMultiSelection = true
        }
        mainTV.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
    }

    override func willMove(toParentViewController parent: UIViewController?) {
        if parent == nil { albumCoverImageView.alpha = 0 }
    }

    override func viewWillDisappear(_ animated: Bool) {
        recorderCell?.isActive = false
    }
    override func viewDidDisappear(_ animated: Bool) {
        closeRecordingCell()
    }
}

// MARK: TableView Delegate
extension DetailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { return Section.cases }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && indexPath.item == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "detailHeaderCell", for: indexPath) as! DetailHeaderCell
            cell.postInfo = self.post
            return cell
        }else if indexPath.section == 0 && indexPath.item == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "masterWaveCell", for: indexPath)
            masterWaveCell = cell as? MasterWaveFormViewCell
            return masterWaveCell!
        }
        else if Section(rawValue: indexPath.section) == .MixedTrackToggler {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MixedCommentHeaderCell", for: indexPath) as! ModeToggleCell
            cell.delegate = self
            mixedTrackToggler = cell
            return cell
        }else if Section(rawValue: indexPath.section) == .CommentTrackToggler {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTracksHeaderCell", for: indexPath) as! ModeToggleCell
            cell.delegate = self
            commentTrackToggler = cell
            return cell
        }else if Section(rawValue: indexPath.section) == .MixedTracks {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MixedTracksContainer", for: indexPath) as! CommentContainerCell
            cell.allComments = post.mixed_tracks
            cell.delegate = self
            mixedTrackContainer = cell
            mixedTrackToggler?.containerToToggle = cell
            return cell
        }else if Section(rawValue: indexPath.section) == .CommentTracks {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTracksContainer", for: indexPath) as! CommentContainerCell
            cell.allComments = post.comment_tracks; cell.delegate = self
            if DataCenter.main.userId == post.author?.id { cell.commentTV.allowsMultipleSelection = true }
            commentTrackContainer = cell
            commentTrackToggler?.containerToToggle = cell
            return cell
        }else if Section(rawValue: indexPath.section) == .RecordCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "recorderCell", for: indexPath) as! RecorderCell
            cell.delegate = self
            recorderCell = cell
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if Section(rawValue: indexPath.section) == .MainHeader { return 200 }
        else if Section(rawValue: indexPath.section) == .MixedTrackToggler { return 60 }
        else if Section(rawValue: indexPath.section) == .CommentTrackToggler { return 60 }
        else if Section(rawValue: indexPath.section) == .MixedTracks {
            return CGFloat(post.numOfMixedTracks * 100)
        }else if Section(rawValue: indexPath.section) == .CommentTracks {
            return CGFloat(post.numOfCommentTracks * 100)
        }
        return heightOfRecordingCell
    }
}

// MARK: 모드가 변경되었을 때 처리
extension DetailViewController: ModeToggleCellDelegate {
    func didModeToggled(to mode: Bool, by toggler: CommentContainerCell?) {
        toggler?.setMute(to: !mode)
        toggler?.setInteractionability(to: mode)
        guard let mixed = mixedTrackContainer, let comment = commentTrackContainer else { return }
        if mixed.isMuted == true && comment.isMuted == true {
            authorTrackPlayer?.isMuted = true; masterTrackPlayer?.isMuted = false
        }else{
            authorTrackPlayer?.isMuted = false; masterTrackPlayer?.isMuted = true
        }
    }
}

// MARK: Playable 프로토콜 구현
extension DetailViewController: Playable {
    func reflect(progress: Float) {
        self.masterWaveCell?.reflect(progress: progress)
    }

    func stop() {
        for player in allAudioPlayers { player?.stop() }
    }

    func play() {
        for player in allAudioPlayers { player?.play() }
    }

    func pause() {
        for player in allAudioPlayers { player?.pause() }
    }

    func seek(to point: Float) {
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

// MARK: CommentContainerCellDelegate
extension DetailViewController: CommentContainerCellDelegate {
    func didStartDownloading() {
        PlayBarController.main.lastPhase = PlayBarController.main.currentPhase
        PlayBarController.main.pause()
        PlayBarController.main.isEnabled = false
    }

    func didFinishedDownloading() {
        PlayBarController.main.isEnabled = true
        PlayBarController.main.seek(to: PlayBarController.main.progress)
        if PlayBarController.main.lastPhase == .Playing {
            PlayBarController.main.play()
        }
    }

    func shouldShowProfileOf(user: User?) {
        let profileVC = UIStoryboard(name: "SideMenu", bundle: nil)
            .instantiateViewController(withIdentifier: "profileViewController") as! ProfileViewController
        profileVC.userInfo = user
        navigationController?.pushViewController(profileVC, animated: true)
    }

    func didSelectionOccured(on comments: [Comment]) {
        if navigationItem.rightBarButtonItems?.count == 1 {
            navigationItem.rightBarButtonItems?.append(UIBarButtonItem(title: "Merge", style: .plain, target: self, action: #selector(mix)))
        }
        if comments.isEmpty {
            navigationItem.rightBarButtonItem = nil
            let sideMenuButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "Hamburger_icon"), style: .plain, target: self, action: #selector(showsidemenu))
            navigationItem.rightBarButtonItem = sideMenuButton
        }
        selectedComments = comments
    }
    @objc func showsidemenu() {
        self.showSideMenu()
    }

    @objc private func mix() {
        guard let selectedComments = selectedComments else { return }
        var comments: [Int] = []
        for comment in selectedComments {
            guard let commentId = comment.id else {
                self.mixedTrackContainer?.allowsMultiSelection = false
                _ = self.navigationItem.rightBarButtonItems?.popLast()
                return
            }
            comments.append(commentId)
        }
        guard let postId = post.id else { return }
        NetworkController.main.mix(comments: comments, on: postId, completion: {
            NetworkController.main.fetchPost(id: postId, completion: { (post) in
                self.post = post
                self.mixedTrackContainer?.isNewTrackBeingAdded = true
                let ids = IndexSet(integersIn: Section.MixedTracks.rawValue ... Section.MixedTracks.rawValue)
                self.mainTV.reloadSections(ids, with: .automatic)
                self.mixedTrackContainer?.allowsMultiSelection = false
                _ = self.navigationItem.rightBarButtonItems?.popLast()
            })
        })
    }
}

//MARK: RecorderCellDelegate
extension DetailViewController: RecorderCellDelegate {

    func didStartRecording() {
        PlayBarController.main.currentPhase = .Recording
    }

    func didStopRecording() {
        PlayBarController.main.currentPhase = .Stopped
    }

    func didStartPlayingRecordedAudio() {
        PlayBarController.main.currentPhase = .PlayingRecord
    }

    func didStoppedPlayingRecorededAudio() {
        PlayBarController.main.currentPhase = .Stopped
    }

    func shouldRequireLogin() {
        alert(msg: "로그인이 필요한 기능입니다")
    }

    func shouldBecomeActive() {
        UIView.animate(withDuration: 0.5) {
            self.recorderCell?.backgroundColor = .black
        }
        heightOfRecordingCell = CGFloat(UIScreen.main.bounds.height - PlayBarController.main.view.frame.height - (navigationController?.navigationBar.frame.height ?? 0) - 20)
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.mainTV.scrollToRow(at: IndexPath(item: 0, section: Section.RecordCell.rawValue), at: .bottom, animated: true)
            self.recorderCell?.isActive = true
        }
        mainTV.beginUpdates()
        mainTV.endUpdates()
        CATransaction.commit()
    }

    func uploadDidFinished(with post: Post?) {
        guard let post = post else { return }
        self.post = post
        mainTV.reloadData()
    }

    func shouldShowAlert() {
        let alert = UIAlertController(title: "녹음 업로드", message: "녹음을 업로드 하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .cancel, handler: { (action) in
            self.showInstrumentPicker()
        }))
        alert.addAction(UIAlertAction(title: "취소", style: .destructive, handler: { (action) in
            RecordConductor.main.resetRecorder()
        }))
        present(alert, animated: true, completion: nil)
    }

    func showInstrumentPicker() {
        ActionSheetStringPicker.show(withTitle: "어떤 악기였나요?", rows: Instrument.cases, initialSelection: 0, doneBlock: { (picker, row, result) in

            let selectedInstrument = Instrument.cases[row]
            guard let postId = self.post.id else { return }
            RecordConductor.main.confirmComment(on: postId, of: selectedInstrument, completion: { (postResult) in
                guard let postResult = postResult else { return }
                self.post = postResult
                self.commentTrackContainer?.isNewTrackBeingAdded = true
                self.closeRecordingCell()
            })
        }, cancel: { (picker) in
        }, origin: self.view)
    }
    private func closeRecordingCell() {
        self.heightOfRecordingCell = 50
        self.recorderCell?.isActive = false
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.mainTV.scrollToRow(at: IndexPath(item: 0, section: Section.RecordCell.rawValue), at: .bottom, animated: true)
        }
        self.mainTV.beginUpdates()
        self.mainTV.endUpdates()
        CATransaction.commit()
    }
}

extension DetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let heightOfPopBackGestureDisableZone: CGFloat = 30
        return touch.location(in: PlayBarController.main.view).y < -heightOfPopBackGestureDisableZone
    }

    @objc private func onPopBackHandler(sender: UIGestureRecognizer) {
        switch sender.state {
        case .began, .changed:
            if let coord = navigationController?.transitionCoordinator {
                currentTransitionCoordinator = coord
            }
        case .cancelled, .ended:
            currentTransitionCoordinator = nil
        case .possible, .failed:
            break
        }
        if let currentTransitionCoordinator = currentTransitionCoordinator {
            albumCoverImageView.alpha = 1 - currentTransitionCoordinator.percentComplete
        }
    }
}

// MARK: Helper Enums
extension DetailViewController {
    private enum Section: Int {
        case MainHeader = 0
        case MixedTrackToggler = 1
        case MixedTracks = 2
        case CommentTrackToggler = 3
        case CommentTracks = 4
        case RecordCell = 5
        /**
         모든 Section의 경우의 수

         MainHeader / MixedHeader/ Mixed / CommentHeader / Comment / Recorder
        */
        static var cases = 6
    }
}

protocol Playable {
    func play()
    func pause()
    func stop()
    func seek(to point: Float)
    func setVolume(to value: Float)
    func setMute(to value: Bool)
}

extension DetailViewController {
    private func render(_ masterWaveCell: MasterWaveFormViewCell) {
        if let masterPlayer = self.masterTrackPlayer {
            masterWaveCell.masterAudioURL = (masterPlayer.currentItem?.asset as? AVURLAsset)?.url
        }else{
            NotificationCenter.default.addObserver(forName: NSNotification.Name("MasterTrackDownloaded"), object: nil, queue: nil, using: { (noti) in
                self.masterWaveCell?.masterAudioURL = (self.masterTrackPlayer?.currentItem?.asset as? AVURLAsset)?.url
            })
        }
    }

    private func setUp(_ player: AVPlayer?, with url: URL?) {
        PlayBarController.main.isEnabled = false
        guard let url = url else { return }
        NetworkController.main.downloadAudio(from: url) { (localURL) in
            player?.replaceCurrentItem(with: AVPlayerItem(url: localURL))
            PlayBarController.main.isEnabled = true
        }
    }

    private func setUpMasterPlayer() {
        PlayBarController.main.isEnabled = false
        if let materRemoteURL = self.post.masterTrackRemoteURL {
            NetworkController.main.downloadAudio(from: materRemoteURL, completion: { (localURL) in
                self.masterTrackPlayer = AVPlayer(url: localURL)
                PlayBarController.main.isEnabled = true
            })
        }
    }

    private func setUpAuthorTrackPlayer() {
        if let authorRemoteURL = self.post.authorTrackRemoteURL {
            self.authorTrackPlayer = AVPlayer(url: authorRemoteURL)
            self.authorTrackPlayer?.isMuted = true
        }
    }

    private func removeGlobalTimeObserver(from player: AVPlayer) {
        if AVPlayerTimeObserver != nil && player === AVPlayerTimeObserver?.observer {
            player.removeTimeObserver(AVPlayerTimeObserver!.observee!)
        }
    }

    private func addGlobalTimeObserver(on player: AVPlayer) {
        let cmt = CMTime(value: 1, timescale: 10)
        AVPlayerTimeObserver = PlayerTimeObserver()
        AVPlayerTimeObserver?.observer = player
        AVPlayerTimeObserver?.observee = player.addPeriodicTimeObserver(forInterval: cmt, queue: DispatchQueue.main, using: { (cmt) in
            if player.isPlaying { PlayBarController.main.reflect(progress: player.progress) }
        })
    }

    private func fillContainers() {
        NetworkController.main.fetchPost(id: (post?.id ?? -1)) { (postResult) in
            self.post = postResult
            let ids = IndexSet(integersIn: Section.MixedTracks.rawValue ... Section.CommentTracks.rawValue)
            self.mainTV.reloadSections(ids, with: .automatic)
        }
    }

    /**
     특정 post를 보여주는 DetailViewController로 이동하는 함수
     - parameter post : 도착한 DetailVC가 보여줘야 할 post 정보
     - parameter vc : 출발하는 ViewController
     */
    static func goToDetailPage(of post: Post, from vc: UIViewController) {
        /// 보려는 포스트가, 현재 플레이바에서 재생중인 포스트라면
        if post.id == PlayBarController.main.currentPostView?.post.id {
            /// 그 포스트객체는 PlayBarController.main에 저장되어 있으니, 그걸 보여주면 됨.
            vc.navigationController?.show(PlayBarController.main.currentPostView!, sender: nil)
        }else {
            /// 그게 아니라면, 프로필 페이지에 있는 Post객체는 제한된 정보만 가지고 있기 때문에,
            /// 온전한 Post객체를 다시 서버에서 받아와야 함.
            guard let postId = post.id else { return }
            NetworkController.main.fetchPost(id: postId) { (fetchedPost) in
                let nextVC = UIStoryboard(name: "Detail", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
                nextVC.post = fetchedPost
                vc.navigationController?.show(nextVC, sender: nil)
            }
        }
    }
}
