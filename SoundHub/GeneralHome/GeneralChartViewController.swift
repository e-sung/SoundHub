//
//  GeneralChartViewController.swift
//  soundHubPractice
//
//  Created by 류성두 on 2017. 11. 26..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit


class GeneralChartViewController: UIViewController{
    
    var tapOnMoreRanking = 1
    var tapOnMoreRecent = 1
    let sectionTitleList = ["CategoryTab", "Popular Musicians", "Ranking Chart", "Recent Upload"]

    @IBOutlet weak var mainTV: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        mainTV.delegate = self
        mainTV.dataSource = self
        NetworkController.main.fetchRecentPost(on: mainTV)
    }

}

extension GeneralChartViewController:UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitleList.count
    }
    
    func getHeaderHeighFor(given section:Int)->CGFloat{
        if Section(rawValue: section) == .PopularMusicians{return 50.0}
        else{return 100.0}
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if Section(rawValue: section) == .CategoryTab{return nil}
        let headerView = generateHeaderViewFor(given: section)
        let headerLabel = generateHeaderLableFor(given: section, with: headerView)
        headerView.addSubview(headerLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section < Section.RankingChart.rawValue {return nil}
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        let seeMoreButton = generateSeeMoreButtonFor(given: section, with: footerView, and: "See more")
        footerView.addSubview(seeMoreButton)
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if Section(rawValue: section) == .CategoryTab{
            return 0.1
        }else if Section(rawValue: section) == .PopularMusicians{
            return 50
        }else{
            return 100
        }
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section < Section.RankingChart.rawValue {return 10}
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Section(rawValue: section) == .RankingChart{
            return tapOnMoreRanking * 3
        }else if Section(rawValue: section) == .RecentUpload{
            return NetworkController.main.recentPosts.count
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "categoryTab", for: indexPath)
        }else if indexPath.section == 1{
            return tableView.dequeueReusableCell(withIdentifier: "popularMusicianContainerCell", for: indexPath)
        }else if Section(rawValue: indexPath.section) == .RankingChart{
            return tableView.dequeueReusableCell(withIdentifier: "rankingCell", for: indexPath) as! PostListCell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "recentUploadCell", for: indexPath) as! PostListCell
            if NetworkController.main.recentPosts.count - 1 >= indexPath.item{
                cell.postInfo = NetworkController.main.recentPosts[indexPath.item]
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if Section(rawValue: indexPath.section) == .CategoryTab{
            return 50
        }else if Section(rawValue: indexPath.section) == .PopularMusicians{
            return 200
        }else{
            return 500
        }
    }

}

extension GeneralChartViewController{
    func generateHeaderViewFor(given section:Int)->UIView{
        let headerView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 0))
        headerView.setHeight(with: getHeaderHeighFor(given: section))
        headerView.backgroundColor = .white
        return headerView
    }
    
    func generateHeaderLableFor(given section:Int, with parentView:UIView)->UILabel{
        let headerLabel = UILabel(frame: parentView.frame)
        headerLabel.text = sectionTitleList[section]
        headerLabel.font = headerLabel.font.withSize(30)
        return headerLabel
    }

    func generateSeeMoreButtonFor(given section:Int, with parentView:UIView, and title:String)->UIButton{
        let seeMoreButton = UIButton(frame: parentView.frame)
        seeMoreButton.setTitle(title, for: .normal)
        seeMoreButton.tag = section
        seeMoreButton.addTarget(self, action: #selector(seeMoreButtonTapHandler), for: .touchUpInside)
        return seeMoreButton
    }
}

extension GeneralChartViewController{
    @objc func seeMoreButtonTapHandler(sender:UIButton){
        if Section(rawValue: sender.tag) == .RankingChart{
            if tapOnMoreRanking < 3 {
                tapOnMoreRanking += 1
            }
        }else{
            if tapOnMoreRecent < 3 {
                tapOnMoreRecent += 1
            }
        }
        mainTV.reloadSections(IndexSet(integer: sender.tag), with: .automatic)
    }
}

fileprivate enum Section:Int{
    case CategoryTab = 0
    case PopularMusicians = 1
    case RankingChart = 2
    case RecentUpload = 3
}
