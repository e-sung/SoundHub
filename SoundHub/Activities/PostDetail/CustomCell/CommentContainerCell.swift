//
//  MixedTracksContainerCell.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 12. 8..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit
import AVFoundation

class CommentContainerCell: UITableViewCell {

    var allComments:[String:[Comment]]? {
        didSet(oldval) {
            if oldval == nil || isNewTrackBeingAdded {
                commentTV.reloadData()
                isNewTrackBeingAdded = false
            }
        }
    }
    var aPlayer: AVPlayer?
    var numberOfPlayersBeingDownloaded = 0
    weak var delegate: CommentContainerCellDelegate?
    var isNewTrackBeingAdded = false
    private var allCells: [AudioCommentCell] {
        var cells: [AudioCommentCell] = []
        for i in 0..<commentTV.numberOfSections {
            for j in 0..<commentTV.numberOfRows(inSection: i) {
                if let cell = commentTV.cellForRow(at: IndexPath(item: j, section: i)) as? AudioCommentCell {
                    cells.append(cell)
                }
            }
        }
        return cells
    }
    var allowsMultiSelection: Bool {
        get { return commentTV.allowsMultipleSelection }
        set (newVal) { commentTV.allowsMultipleSelection = newVal }
    }

    @IBOutlet weak var commentTV: UITableView!

    override func awakeFromNib() {
        super.awakeFromNib()
        commentTV.delegate = self
        commentTV.dataSource = self
    }

}

extension CommentContainerCell: Playable {
    // MARK: Play and Pause Functions
    func setInteractionability(to bool: Bool) {
        for cell in allCells { cell.isInterActive = bool }
    }

    func play() {
        for cell in allCells { cell.play() }
    }

    func pause() {
        for cell in allCells { cell.pause() }
    }

    func stop() {
        for cell in allCells { cell.stop() }
    }

    func seek(to proportion: Float) {
        for cell in allCells { cell.seek(to: proportion) }
    }

    func setVolume(to value: Float) {
        for cell in allCells { if cell.isActive { cell.setVolume(to: value)} }
    }

    func setMute(to value: Bool) {
        for cell in allCells { if cell.isActive { cell.setMute(to: value) } }
    }
    var isMuted: Bool {
        guard let aPlayer = aPlayer else { return true}
        return aPlayer.isMuted
    }
}

extension CommentContainerCell: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Instrument.cases.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let instrument = Instrument.cases[section]
        if let allComments = allComments {
            if allComments.keys.contains(instrument) { return allComments[instrument]!.count }
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mixedTrackCell", for: indexPath) as! AudioCommentCell
        let instrument = Instrument.cases[indexPath.section]
        if let allComments = allComments {
            if allComments.keys.contains(instrument) {
                cell.comment = allComments[instrument]![indexPath.item]
            }
        }
        if indexPath == IndexPath(item: 0, section: 1) { aPlayer = cell.player }
        if tableView.allowsMultipleSelection == true { cell.borderWidth = 2; cell.borderColor = .orange }
        cell.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let comments = getComments(In: selectedCells)
        delegate?.didSelectionOccured(on: comments)
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let comments = getComments(In: selectedCells)
        delegate?.didSelectionOccured(on: comments)
    }
    private var selectedCells: [AudioCommentCell] {
        var selectedCells: [AudioCommentCell] = []
        if let selectedIndexes = commentTV.indexPathsForSelectedRows {
            for idx in selectedIndexes {
                let cell = commentTV.cellForRow(at: idx) as! AudioCommentCell
                selectedCells.append(cell)
            }
        }
        return selectedCells
    }
    private func getComments(In cells: [AudioCommentCell]) -> [Comment] {
        var array: [Comment] = []
        for cell in cells {
            array.append(cell.comment)
        }
        return array
    }
}

extension CommentContainerCell: AudioCommentCellDelegate {
    func didStartDownloading() {
        numberOfPlayersBeingDownloaded += 1
        delegate?.didStartDownloading()
    }

    func didFinishedDownloading() {
        numberOfPlayersBeingDownloaded -= 1
        if numberOfPlayersBeingDownloaded == 0 {
            delegate?.didFinishedDownloading()
        }
    }

    func shouldShowProfileOf(user: User?) {
        self.delegate?.shouldShowProfileOf(user: user)
    }
}

protocol CommentContainerCellDelegate: class {
    func didSelectionOccured(on comments: [Comment])
    func shouldShowProfileOf(user: User?)
    func didStartDownloading()
    func didFinishedDownloading()
}
