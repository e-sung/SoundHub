//
//  PopularMusicianContainerCell.swift
//  soundHubPractice
//
//  Created by 류성두 on 2017. 11. 26..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit

class PopularMusicianContainerCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "popularMusician", for: indexPath) as! PopularMusicianCell
        cell.artistImage.backgroundColor = UIColor(red: 0.1, green: CGFloat(indexPath.item)*0.1, blue: 0.1, alpha: 1)
        cell.artistNameLabel.text = "\(indexPath)"
        return cell
    }
    

    @IBOutlet weak var popularMusicianFlowLayout: UICollectionView!
    override func awakeFromNib() {
        super.awakeFromNib()
        popularMusicianFlowLayout.delegate = self
        popularMusicianFlowLayout.dataSource = self
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
