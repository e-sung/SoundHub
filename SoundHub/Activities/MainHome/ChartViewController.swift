//
//  GeneralChartViewController.swift
//  soundHubPractice
//
//  Created by 류성두 on 2017. 11. 26..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit
import AlamofireImage


class ChartViewController: UIViewController{
    
    // MARK: IBOutlets
    @IBOutlet weak private var mainTV: UITableView!
    
    // MARK: IBAction
    @IBAction func unwindToChart(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
    }
    
    // MARK: Stored Properties
    private var tapOnMoreRanking = 1
    private var tapOnMoreRecent = 1
    private let sectionTitleList = ["CategoryTab", "Popular Musicians", "Ranking Chart", "Recent Upload"]
    var category:Categori = .general
    var option:String = ""
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        mainTV.delegate = self
        mainTV.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if PlayBarController.main.isHidden == false {
            mainTV.bottomAnchor.constraint(equalTo: self.view.bottomAnchor,
                                           constant: -(PlayBarController.main.view.frame.height)).isActive = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {

        if DataCenter.main.homePages[category]?.recent_posts.count == 0{
            performSegue(withIdentifier: "showLoadingIndicatingView", sender:self)
        }
        NetworkController.main.fetchHomePage(of: category, with: option) {
            DispatchQueue.main.async {
                self.refreshData()
                if let loadIndicator = self.presentedViewController as? LoadingIndicatorViewController {
                    loadIndicator.activityIndicator.stopAnimating()
                    loadIndicator.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}

//MARK: TableViewDataSource
extension ChartViewController:UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitleList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Section(rawValue: section) == .RankingChart{
            if tapOnMoreRanking * 3 > DataCenter.main.homePages[category]!.pop_posts.count{
                return DataCenter.main.homePages[category]!.pop_posts.count
            } else {return tapOnMoreRanking * 3 }
        }else if Section(rawValue: section) == .RecentUpload{
            if tapOnMoreRecent * 3 > DataCenter.main.homePages[category]!.recent_posts.count{
                return DataCenter.main.homePages[category]!.recent_posts.count
            }else{ return tapOnMoreRecent * 3 }
        }else{ return 1 }
    }
}

// MARK: TableViewDelegate
extension ChartViewController:UITableViewDelegate{

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if Section(rawValue: section) == .CategoryTab {return nil}
        return generateHeaderViewFor(given: section)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section < Section.RankingChart.rawValue {return nil}
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        let seeMoreButton = generateSeeMoreButtonFor(given: section, with: footerView, and: "See more")
        footerView.addSubview(seeMoreButton)
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Section(rawValue: section)!.headerHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section < Section.RankingChart.rawValue {return 10}
        else {return 50}
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var posts:[Post] = []
        if Section(rawValue: indexPath.section) == .CategoryTab {
            return tableView.dequeueReusableCell(withIdentifier: "categoryTab", for: indexPath)
        }else if Section(rawValue: indexPath.section) == .PopularMusicians{
            let cell = tableView.dequeueReusableCell(withIdentifier: "popularMusicianContainerCell", for: indexPath) as! PopularMusicianContainerCell
            cell.delegate = self
            return cell
        }else if Section(rawValue: indexPath.section) == .RankingChart{
            let cell = tableView.dequeueReusableCell(withIdentifier: "rankingCell", for: indexPath) as! PostListCell
            posts = DataCenter.main.homePages[category]!.pop_posts
            cell.delegate = self
            if posts.count > indexPath.item { cell.postInfo = posts[indexPath.item] }
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "recentUploadCell", for: indexPath) as! PostListCell
            posts = DataCenter.main.homePages[category]!.recent_posts
            cell.delegate = self
            if posts.count > indexPath.item { cell.postInfo = posts[indexPath.item] }
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? PostListCell else { return }
        if Section(rawValue: indexPath.section) == .RankingChart{
            guard let url = DataCenter.main.homePages[category]?.pop_posts[indexPath.item].author?.profileImageURL else { return }
            cell.authorProfileImageBt.af_setImage(for: .normal, url:url)
        }else if Section(rawValue: indexPath.section) == .RecentUpload{
            guard let url = DataCenter.main.homePages[category]?.recent_posts[indexPath.item].author?.profileImageURL else { return }
            cell.authorProfileImageBt.af_setImage(for: .normal, url:url)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Section(rawValue: indexPath.section)!.rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let destinationPost:Post? = getDestinationPost(from: indexPath)
        if destinationPost?.author_track != PlayBarController.main.currentPostView?.post.author_track{
            performSegue(withIdentifier: "generalChartToDetail", sender: indexPath)
        }else{
            navigationController?.show((PlayBarController.main.currentPostView)!, sender: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return PostListCell.defaultHeight
    }
    
    func refreshData(){
        mainTV.reloadData()
        guard let popularMusiciansContainer = mainTV.cellForRow(at: IndexPath(item: 0, section: Section.PopularMusicians.rawValue)) as? PopularMusicianContainerCell else { return }
        popularMusiciansContainer.category = category
        popularMusiciansContainer.popularMusicianFlowLayout.reloadData()
    }
}

extension ChartViewController{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nextVC = segue.destination as? DetailViewController{
            let indexPath = sender as! IndexPath
            if Section(rawValue: indexPath.section) == .RankingChart{
                nextVC.post = DataCenter.main.homePages[category]!.pop_posts[indexPath.item]
            }else{
                nextVC.post = DataCenter.main.homePages[category]!.recent_posts[indexPath.item]
            }
        }
    }
}

extension ChartViewController:PostListCellDelegate{
    func shouldShowProfile(of user: User?) {
        let profileVC = UIStoryboard(name: "SideMenu", bundle: nil)
            .instantiateViewController(withIdentifier: "profileViewController") as! ProfileViewController
        profileVC.userInfo = user
        navigationController?.pushViewController(profileVC, animated: true)
    }
}

extension ChartViewController{
    private func generateHeaderViewFor(given section:Int)->UIView{
        let title = sectionTitleList[section]
        let height = Section(rawValue: section)!.headerHeight
        return UIView.generateHeaderView(with: title, and: Int(height))
    }

    private func generateSeeMoreButtonFor(given section:Int, with parentView:UIView, and title:String)->UIButton{
        let seeMoreButton = UIButton(frame: parentView.frame)
        seeMoreButton.setTitle(title, for: .normal)
        seeMoreButton.tag = section
        seeMoreButton.addTarget(self, action: #selector(seeMoreButtonTapHandler), for: .touchUpInside)
        return seeMoreButton
    }
    
    func getDestinationPost(from indexPath:IndexPath)->Post?{
        var destinationPost:Post? = nil
        if Section(rawValue: indexPath.section) == .RankingChart{
            destinationPost = DataCenter.main.homePages[category]?.pop_posts[indexPath.item]
        }else{
            destinationPost = DataCenter.main.homePages[category]?.recent_posts[indexPath.item]
        }
        return destinationPost
    }
}

extension ChartViewController{
    @objc private func seeMoreButtonTapHandler(sender:UIButton){
        if Section(rawValue: sender.tag) == .RankingChart {tapOnMoreRanking += 1}
        else if Section(rawValue: sender.tag) == .RecentUpload {tapOnMoreRecent += 1}
        mainTV.reloadData()
    }
}

extension ChartViewController{
    private enum Section:Int{
        case CategoryTab = 0
        case PopularMusicians = 1
        case RankingChart = 2
        case RecentUpload = 3
        
        var headerHeight:CGFloat{
            switch self {
            case .CategoryTab:
                return 0.1
            case .PopularMusicians:
                return 50
            default:
                return 60
            }
        }
        
        var rowHeight:CGFloat{
            switch self {
            case .CategoryTab:
                return 50
            case .PopularMusicians:
                return 200
            default:
                return PostListCell.defaultHeight
            }
        }
    }
}
