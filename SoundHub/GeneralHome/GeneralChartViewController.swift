//
//  GeneralChartViewController.swift
//  soundHubPractice
//
//  Created by 류성두 on 2017. 11. 26..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit

class GeneralChartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var tapOnMoreRanking = 1
    var tapOnMoreRecent = 1
    
    @IBOutlet weak var mainTV: UITableView!
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {return nil}
        
        let headerView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 0))
        if section == 1 {headerView.setHeight(with: 50)}
        else {headerView.setHeight(with: 100)}
        headerView.backgroundColor = .white
        
        let headerLabel = UILabel(frame: headerView.frame)
        switch section {
        case 1:
            headerLabel.text = "Popular Musicians"
        case 2:
            headerLabel.text = "Ranking Chart"
        case 3:
            headerLabel.text = "Recent upload"
        default:
            print("Unexpected section")
        }
        headerLabel.font = headerLabel.font.withSize(30)
        
        headerView.addSubview(headerLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section < 2 {return nil}
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        let seeMoreButton = UIButton(frame: footerView.frame)
        seeMoreButton.setTitle("See more", for: .normal)
        seeMoreButton.tag = section
        seeMoreButton.addTarget(self, action: #selector(seeMoreButtonTapHandler), for: .touchUpInside)
        footerView.addSubview(seeMoreButton)
        return footerView
    }
    
    @objc func seeMoreButtonTapHandler(sender:UIButton){
        if sender.tag == 2 {
            tapOnMoreRanking += 1
        }else{
            tapOnMoreRecent += 1
        }
        mainTV.reloadSections( IndexSet(integer: sender.tag), with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.1
        }else if section == 1{
            return 50
        }else{
            return 100
        }
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section < 2 {return 10}
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return tapOnMoreRanking * 3
        case 3:
            return tapOnMoreRecent * 3
        default:
            print("Unexpected section")
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "categoryTab", for: indexPath)
        }else if indexPath.section == 1{
            return tableView.dequeueReusableCell(withIdentifier: "popularMusicianContainerCell", for: indexPath)
        }else{
            return tableView.dequeueReusableCell(withIdentifier: "rankingCell", for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 50
        }else if indexPath.section == 1 { 
            return 200
        }else{
            return 500
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        mainTV.delegate = self
        mainTV.dataSource = self
        // Do any additional setup after loading the view.
    }

}
