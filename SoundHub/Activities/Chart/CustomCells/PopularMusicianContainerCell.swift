//
//  PopularMusicianContainerCell.swift
//  soundHubPractice
//
//  Created by 류성두 on 2017. 11. 26..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit

class PopularMusicianContainerCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var popularMusicianFlowLayout: UICollectionView!
    var category:Categori = .general
    weak var delegate:ChartViewController?
    override func awakeFromNib() {
        super.awakeFromNib()
        popularMusicianFlowLayout.delegate = self
        popularMusicianFlowLayout.dataSource = self
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("shouldReloadCells"), object: nil, queue: nil) { (noti) in
            DispatchQueue.main.async { self.popularMusicianFlowLayout.reloadData() }
        }
    }
    
    // MARK: CollectionViewDelegates
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "popularMusician", for: indexPath) as! PopularMusicianCell
        if DataCenter.main.homePages[category]!.pop_users.count > indexPath.item {
            let userInfo = DataCenter.main.homePages[category]!.pop_users[indexPath.item]
            cell.userInfo = userInfo
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let musician = DataCenter.main.homePages[category]!.pop_users[indexPath.item]
        let storyboard = UIStoryboard(name: "SideMenu", bundle: nil)
        let profileVC = storyboard.instantiateViewController(withIdentifier: "profileViewController") as! ProfileViewController
        profileVC.userInfo = musician
        delegate?.show(profileVC, sender: nil)
    }
}
