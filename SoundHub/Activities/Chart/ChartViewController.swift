//
//  GeneralChartViewController.swift
//  soundHubPractice
//
//  Created by 류성두 on 2017. 11. 26..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit
import AlamofireImage

class ChartViewController: UIViewController {
    let recorder = RecordConductor.main
    // MARK: IBOutlets
    @IBOutlet weak private var mainTV: UITableView!
    @IBOutlet weak var mainTVBottomConstraint: NSLayoutConstraint!

    // MARK: IBAction
    @IBAction func unwindToChart(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        self.refreshData()
    }

    // MARK: Stored Properties
    private var tapOnMoreRanking = 1
    private var tapOnMoreRecent = 1
    private let sectionTitleList = ["CategoryTab", "Popular Musicians", "Ranking Chart", "Recent Upload"]
    var category: Categori = .general
    var option: String = ""
    var shouldScrollToTop = false

    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        fill(In: DataCenter.main, with: UserDefaults.standard)

        mainTV.delegate = self
        mainTV.dataSource = self
        navigationController?.delegate = self
        NotificationCenter.default.addObserver(forName: NSNotification.Name("shouldReloadContents"), object: nil, queue: nil) { (noti) in
            self.reloadContents(showingLoadingIndicator: true)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        if shouldScrollToTop {
            mainTV.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
            shouldScrollToTop = false
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        if DataCenter.main.homePages[category]?.recent_posts.isEmpty == true { reloadContents(showingLoadingIndicator: true) }
        else { reloadContents(showingLoadingIndicator: false) }
        setUpUI(with: PlayBarController.main)
    }
}

// MARK: TableViewDataSource
extension ChartViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitleList.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Section(rawValue: section) == .RankingChart {
            if tapOnMoreRanking * 3 > DataCenter.main.homePages[category]!.pop_posts.count {
                return DataCenter.main.homePages[category]!.pop_posts.count
            } else {return tapOnMoreRanking * 3 }
        }else if Section(rawValue: section) == .RecentUpload {
            if tapOnMoreRecent * 3 > DataCenter.main.homePages[category]!.recent_posts.count {
                return DataCenter.main.homePages[category]!.recent_posts.count
            }else { return tapOnMoreRecent * 3 }
        }else { return 1 }
    }
}

// MARK: TableViewDelegate
extension ChartViewController: UITableViewDelegate {

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
        var posts: [Post] = []
        if Section(rawValue: indexPath.section) == .CategoryTab {
            return tableView.dequeueReusableCell(withIdentifier: "categoryTab", for: indexPath)
        }else if Section(rawValue: indexPath.section) == .PopularMusicians {
            let cell = tableView.dequeueReusableCell(withIdentifier: "popularMusicianContainerCell", for: indexPath) as! PopularMusicianContainerCell
            cell.delegate = self
            return cell
        }else if Section(rawValue: indexPath.section) == .RankingChart {
            let cell = tableView.dequeueReusableCell(withIdentifier: "rankingCell", for: indexPath) as! PostListCell
            posts = DataCenter.main.homePages[category]!.pop_posts
            cell.delegate = self
            if posts.count > indexPath.item { cell.postInfo = posts[indexPath.item] }
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "recentUploadCell", for: indexPath) as! PostListCell
            posts = DataCenter.main.homePages[category]!.recent_posts
            cell.delegate = self
            if posts.count > indexPath.item { cell.postInfo = posts[indexPath.item] }
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? PostListCell {
            cell.albumCoverImage = #imageLiteral(resourceName: "no_cover")
            cell.profileImage = #imageLiteral(resourceName: "default-profile")
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? PostListCell else { return }
        if Section(rawValue: indexPath.section) == .RankingChart {
            guard let post = DataCenter.main.homePages[category]?.pop_posts[indexPath.item] else { return }
            cell.postInfo = post
        }else if Section(rawValue: indexPath.section) == .RecentUpload {
            guard let post = DataCenter.main.homePages[category]?.recent_posts[indexPath.item] else { return }
            cell.postInfo = post
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Section(rawValue: indexPath.section)!.rowHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let destinationPost: Post? = getDestinationPost(from: indexPath)
        if destinationPost?.id != PlayBarController.main.currentPostView?.post.id {
            performSegue(withIdentifier: "generalChartToDetail", sender: indexPath)
        }else {
            navigationController?.show((PlayBarController.main.currentPostView)!, sender: nil)
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return PostListCell.defaultHeight
    }

    func refreshData() {
        mainTV.reloadData()
        guard let popularMusiciansContainer = mainTV.cellForRow(at: IndexPath(item: 0, section: Section.PopularMusicians.rawValue)) as? PopularMusicianContainerCell else { return }
        popularMusiciansContainer.category = category
        popularMusiciansContainer.popularMusicianFlowLayout.reloadData()
    }
}

extension ChartViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let sideMenuButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "Hamburger_icon"), style: .plain, target: self, action: #selector(showsidemenu))
        viewController.navigationItem.rightBarButtonItem = sideMenuButton
    }
    @objc func showsidemenu() {
        performSegue(withIdentifier: "showSideMenu", sender: nil)
    }
}

extension ChartViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nextVC = segue.destination as? DetailViewController {
            guard let indexPath = sender as? IndexPath else { return }
            if Section(rawValue: indexPath.section) == .RankingChart {
                nextVC.post = DataCenter.main.homePages[category]!.pop_posts[indexPath.item]
            }else {
                nextVC.post = DataCenter.main.homePages[category]!.recent_posts[indexPath.item]
            }
        }
    }
}

extension ChartViewController: PostListCellDelegate {
    func shouldShowProfile(of user: User?) {
        guard let profileVC = UIStoryboard(name: "SideMenu", bundle: nil)
            .instantiateViewController(withIdentifier: "profileViewController") as? ProfileViewController
            else { return }
        profileVC.userInfo = user
        navigationController?.pushViewController(profileVC, animated: true)
    }
}

extension ChartViewController {
    private func generateHeaderViewFor(given section: Int) -> UIView {
        let title = sectionTitleList[section]
        let height = Section(rawValue: section)!.headerHeight
        return UIView.generateHeaderView(with: title, and: Int(height))
    }

    private func generateSeeMoreButtonFor(given section: Int, with parentView: UIView, and title: String) -> UIButton {
        let seeMoreButton = UIButton(frame: parentView.frame)
        seeMoreButton.setTitle(title, for: .normal)
        seeMoreButton.tag = section
        seeMoreButton.addTarget(self, action: #selector(seeMoreButtonTapHandler), for: .touchUpInside)
        return seeMoreButton
    }

    func getDestinationPost(from indexPath: IndexPath) -> Post? {
        var destinationPost: Post? = nil
        if Section(rawValue: indexPath.section) == .RankingChart {
            destinationPost = DataCenter.main.homePages[category]?.pop_posts[indexPath.item]
        }else {
            destinationPost = DataCenter.main.homePages[category]?.recent_posts[indexPath.item]
        }
        return destinationPost
    }
}

extension ChartViewController {
    @objc private func seeMoreButtonTapHandler(sender: UIButton) {
        if Section(rawValue: sender.tag) == .RankingChart {tapOnMoreRanking += 1}
        else if Section(rawValue: sender.tag) == .RecentUpload {tapOnMoreRecent += 1}
        mainTV.reloadData()
    }
}

extension ChartViewController {
    /// 앱을 끄기 직전, dataCenter에 저장된 정보들을 userDefaults에 저장하는데,
    /// 이 함수는 userDefaults에 저장된 정보를 다시 dataCenter으로 불러들임
    private func fill(In dataCenter: DataCenter, with userDefaults: UserDefaults) {
        if let homePageData = userDefaults.object(forKey: "InitialHomepage") as? Data {
            if let homePageInfo = try? JSONDecoder().decode(HomePage.self, from: homePageData) {
                dataCenter.homePages[.general] = homePageInfo
            }
        }
    }

    /// 차트를 갱신함
    private func reloadContents(showingLoadingIndicator: Bool) {
        if self.navigationController?.topViewController as? ChartViewController != nil {
            if showingLoadingIndicator == true {self.showLoadingIndicator()}
        }
        NetworkController.main.fetchHomePage(of: self.category, with: self.option, completion: {
            self.mainTV.reloadData()
            self.presentedViewController?.dismiss(animated: true, completion: nil)
        })
    }

    private func setUpUI(with playBarController: PlayBarController) {
        if playBarController.isHidden == false {
            guard let bottomConstraint = mainTVBottomConstraint else { return }
            bottomConstraint.isActive = false
            mainTV.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(playBarController.view.frame.height)).isActive = true
        }
    }
}

extension ChartViewController {
    private enum Section: Int {
        case CategoryTab = 0
        case PopularMusicians = 1
        case RankingChart = 2
        case RecentUpload = 3

        var headerHeight: CGFloat {
            switch self {
            case .CategoryTab:
                return 0.1
            case .PopularMusicians:
                return 50
            default:
                return 60
            }
        }

        var rowHeight: CGFloat {
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
