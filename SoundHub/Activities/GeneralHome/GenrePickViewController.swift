//
//  GenrePickViewController.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 12. 7..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit

class GenrePickViewController: UIViewController {

    
    @IBOutlet var buttons: [UIButton]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for button in buttons{
            button.addTarget(self, action: #selector(buttonTapHandler) , for: .touchUpInside)
        }
        
        // Do any additional setup after loading the view.
    }
    
    @objc func buttonTapHandler(sender:UIButton){
        let selectedGenre = sender.titleLabel!.text
        performSegue(withIdentifier: "unwindToChart", sender: selectedGenre)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nextVC = segue.destination as? GeneralChartViewController else{
            return
        }
        guard let option = sender as? String else {return}
        nextVC.option = "\(option.lowercased())/"
        nextVC.category = .genre
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
