//
//  AudioUnitSelectingCell.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 12. 19..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit

class AudioUnitContainer: UITableViewCell {

    @IBOutlet weak var audioUnitsFlowLayout: UICollectionView!
    override func awakeFromNib() {
//        audioUnitsFlowLayout.delegate = self
//        audioUnitsFlowLayout.dataSource = self
        super.awakeFromNib()
    }
}
//
//extension AudioUnitContainer: UICollectionViewDataSource{
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        
//    }
//}

