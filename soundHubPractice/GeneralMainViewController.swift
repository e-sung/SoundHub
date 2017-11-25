//
//  GeneralMainViewController.swift
//  soundHubPractice
//
//  Created by 류성두 on 25/11/2017.
//  Copyright © 2017 류성두. All rights reserved.
//

import UIKit

class GeneralMainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rankingCell", for: indexPath)
        cell.backgroundColor = UIColor(red: 0.2, green: CGFloat(indexPath.item)*0.1, blue: 0.1, alpha: 1)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.width
    }
    
    
    @IBOutlet weak var popularCollectionView: UICollectionView!
    
    @IBOutlet weak var rankingTableView: UITableView!
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "popularCell", for: indexPath)
        cell.backgroundColor = UIColor(red: 0.1, green: CGFloat(indexPath.item)*0.1, blue: 0.1, alpha: 1)
        return cell
    }
    


    override func viewDidLoad() {
        super.viewDidLoad()
        popularCollectionView.delegate = self
        popularCollectionView.dataSource = self
        rankingTableView.delegate = self
        rankingTableView.dataSource = self
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
