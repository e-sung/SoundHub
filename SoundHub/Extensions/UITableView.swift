//
//  UITableView.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 12. 18..
//  Copyright © 2017년 류성두. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
    var allCells: [UITableViewCell] {
        var cells: [UITableViewCell] = []
        for i in 0..<self.numberOfSections {
            for j in 0..<self.numberOfRows(inSection: i) {
                if let cell = self.cellForRow(at: IndexPath(item: j, section: i)) {
                    cells.append(cell)
                }
            }
        }
        return cells
    }
}

extension UICollectionView {
    var allCells: [UICollectionViewCell] {
        var cells: [UICollectionViewCell] = []
        for i in 0..<self.numberOfSections {
            for j in 0..<self.numberOfItems(inSection: i) {
                if let cell = self.cellForItem(at: IndexPath(item: j, section: i)) {
                    cells.append(cell)
                }
            }
        }
        return cells
    }
}
