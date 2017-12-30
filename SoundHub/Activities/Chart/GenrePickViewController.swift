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
    
    @IBAction func cancelButtonHandler(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        for button in buttons{
            button.addTarget(self, action: #selector(buttonTapHandler) , for: .touchUpInside)
        }
    }
    
    @objc func buttonTapHandler(sender:UIButton){
        let selectedGenre = sender.titleLabel!.text
        performSegue(withIdentifier: "unwindToChart", sender: selectedGenre)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nextVC = segue.destination as? ChartViewController else{ return }
        guard let option = sender as? String else {return}
        nextVC.option = "\(option.lowercased())/"
        nextVC.category = .genre
    }
}
