//
//  GeneralChartViewController.swift
//  soundHubPractice
//
//  Created by 류성두 on 2017. 11. 26..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit

class GeneralChartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var mainTV: UITableView!
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 0))
        if section > 0 {headerView.setHeight(with: 100)}
        else{headerView.setHeight(with: 50)}
        headerView.backgroundColor = .white
        
        let headerLabel = UILabel(frame: headerView.frame)
        switch section {
        case 0:
            headerLabel.text = "Popular Musicians"
        case 1:
            headerLabel.text = "Ranking Chart"
        case 2:
            headerLabel.text = "Recent upload"
        default:
            print("Unexpected section")
        }
        headerLabel.font = headerLabel.font.withSize(30)
        
        headerView.addSubview(headerLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section>0 ? 100 : 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section > 0 {return 3}else{return 1}
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.item == 0 && indexPath.section == 0{
            return tableView.dequeueReusableCell(withIdentifier: "popularMusicianContainerCell", for: indexPath)
        }else{
            return tableView.dequeueReusableCell(withIdentifier: "rankingCell", for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 { return 200 }
        return 500
    }
    


    override func viewDidLoad() {
        super.viewDidLoad()
        mainTV.delegate = self
        mainTV.dataSource = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
