//
//  GeneralChartViewController.swift
//  soundHubPractice
//
//  Created by 류성두 on 2017. 11. 26..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit


class GeneralChartViewController: UIViewController{
    
    // MARK: IBOutlets
    @IBOutlet weak private var mainTV: UITableView!
    
    // MARK: Stored Properties
    private var tapOnMoreRanking = 1
    private var tapOnMoreRecent = 1
    private let sectionTitleList = ["CategoryTab", "Popular Musicians", "Ranking Chart", "Recent Upload"]
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        mainTV.delegate = self
        mainTV.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NetworkController.main.fetchGeneralHomePage {
            DispatchQueue.main.async { self.mainTV.reloadData() }
        }
        NetworkController.main.fetchRecentPost(on: mainTV)
    }

}

//MARK: TableViewDataSource
extension GeneralChartViewController:UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitleList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Section(rawValue: section) == .RankingChart{
            return tapOnMoreRanking * 3
        }else if Section(rawValue: section) == .RecentUpload{
            if tapOnMoreRecent * 3 > DataCenter.main.recentPosts.count{
                return DataCenter.main.homePages[.general]!.recent_posts.count
            }else{
                return tapOnMoreRecent * 3
            }
        }else{
            return 1
        }
    }
}

// MARK: TableViewDelegate
extension GeneralChartViewController:UITableViewDelegate{

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if Section(rawValue: section) == .CategoryTab {return nil}
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
        if Section(rawValue: section) == .CategoryTab {return 0.1}
        else if Section(rawValue: section) == .PopularMusicians {return 50}
        else {return 100}
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section < Section.RankingChart.rawValue {return 10}
        else {return 50}
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if Section(rawValue: indexPath.section) == .CategoryTab {
            return tableView.dequeueReusableCell(withIdentifier: "categoryTab", for: indexPath)
        }else if Section(rawValue: indexPath.section) == .PopularMusicians{
            return tableView.dequeueReusableCell(withIdentifier: "popularMusicianContainerCell", for: indexPath)
        }else if Section(rawValue: indexPath.section) == .RankingChart{
            let cell = tableView.dequeueReusableCell(withIdentifier: "rankingCell", for: indexPath) as! PostListCell
            var popularPost = DataCenter.main.homePages[.general]!.pop_posts
            if popularPost.count - 1 >= indexPath.item {
                cell.postInfo = popularPost[indexPath.item]
            }
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "recentUploadCell", for: indexPath) as! PostListCell
            var recentPosts = DataCenter.main.homePages[.general]!.recent_posts
            if recentPosts.count - 1 >= indexPath.item {
                cell.postInfo = recentPosts[indexPath.item]
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if Section(rawValue: indexPath.section) == .CategoryTab {return 50}
        else if Section(rawValue: indexPath.section) == .PopularMusicians {return 200}
        else {return 500}
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "generalChartToDetail", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 500
    }
}

extension GeneralChartViewController{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let nextVC = segue.destination as? DetailViewController{
            
            guard let indexPath = sender as? IndexPath else {
                print("indexPath downcasting failed")
                return
            }
            if Section(rawValue: indexPath.section) == .RankingChart{
                nextVC.post = DataCenter.main.homePages[.general]!.pop_posts[indexPath.item]
            }else{
                nextVC.post = DataCenter.main.homePages[.general]!.recent_posts[indexPath.item]
            }
        }
    }
}

extension GeneralChartViewController{
    private func generateHeaderViewFor(given section:Int)->UIView{
        let headerView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 0))
        headerView.setHeight(with: getHeaderHeighFor(given: section))
        headerView.backgroundColor = .white
        return headerView
    }
    
    private func generateHeaderLableFor(given section:Int, with parentView:UIView)->UILabel{
        let headerLabel = UILabel(frame: parentView.frame)
        headerLabel.text = sectionTitleList[section]
        headerLabel.font = headerLabel.font.withSize(30)
        return headerLabel
    }

    private func generateSeeMoreButtonFor(given section:Int, with parentView:UIView, and title:String)->UIButton{
        let seeMoreButton = UIButton(frame: parentView.frame)
        seeMoreButton.setTitle(title, for: .normal)
        seeMoreButton.tag = section
        seeMoreButton.addTarget(self, action: #selector(seeMoreButtonTapHandler), for: .touchUpInside)
        return seeMoreButton
    }
    
    private func getHeaderHeighFor(given section:Int)->CGFloat{
        if Section(rawValue: section) == .PopularMusicians{return 50.0}
        else{return 100.0}
    }
}

extension GeneralChartViewController{
    @objc private func seeMoreButtonTapHandler(sender:UIButton){
        if Section(rawValue: sender.tag) == .RankingChart {tapOnMoreRanking += 1}
        else if Section(rawValue: sender.tag) == .RecentUpload {tapOnMoreRecent += 1}
        mainTV.reloadData()
//        mainTV.reloadSections(IndexSet(integer: sender.tag), with: .bottom)
    }
}

fileprivate enum Section:Int{
    case CategoryTab = 0
    case PopularMusicians = 1
    case RankingChart = 2
    case RecentUpload = 3
}
