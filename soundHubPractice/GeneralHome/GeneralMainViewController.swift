//
//  GeneralMainViewController.swift
//  soundHubPractice
//
//  Created by 류성두 on 25/11/2017.
//  Copyright © 2017 류성두. All rights reserved.
//

import UIKit

class GeneralMainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    @IBOutlet weak var outerScrollView: UIScrollView!
    @IBOutlet weak var popularMusicianCollectionView: UICollectionView!
    @IBOutlet weak var musicRankingTableView: UITableView!


    override func viewDidLoad() {
        super.viewDidLoad()
        outerScrollView.delegate = self
        popularMusicianCollectionView.delegate = self
        popularMusicianCollectionView.dataSource = self
        musicRankingTableView.delegate = self
        musicRankingTableView.dataSource = self
        // Do any additional setup after loading the view.
    }
}

extension GeneralMainViewController{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let foo = 20 + popularMusicianCollectionView.frame.height + 200 + 60
        if scrollView == outerScrollView &&
            scrollView.contentOffset.y >= foo{
            scrollView.isScrollEnabled = false
            musicRankingTableView.isScrollEnabled = true
        }
        
        if scrollView == self.musicRankingTableView &&
            scrollView.contentOffset.y <= 0 {
            self.outerScrollView.isScrollEnabled = true
            musicRankingTableView.isScrollEnabled = false
        }
    }
}

extension GeneralMainViewController{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "popularMusianCell", for: indexPath) as! PopularMusicianCell
        cell.artistImage.backgroundColor = UIColor(red: 0.1, green: CGFloat(indexPath.item)*0.1, blue: 0.1, alpha: 1)
        cell.artistNameLabel.text = "\(indexPath)"
        return cell
    }
}

extension GeneralMainViewController{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100))
        header.backgroundColor = .white
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100))
        titleLabel.text = "Ranking Chart"
        titleLabel.font = titleLabel.font.withSize(40)
        header.addSubview(titleLabel)
        return header
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "Ranking Chart"
//    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rankingCell", for: indexPath)
        cell.backgroundColor = UIColor(red: 0.2, green: CGFloat(indexPath.item)*0.1, blue: 0.1, alpha: 1)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.width
    }
    

    
}
