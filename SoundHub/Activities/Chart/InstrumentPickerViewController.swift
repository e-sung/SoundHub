//
//  InstrumentPickerViewController.swift
//  SoundHub
//
//  Created by 류성두 on 2017. 12. 7..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit

class InstrumentPickerViewController: UIViewController {

    @IBAction func cancelButtonHandler(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet var buttons: [UIButton]!
    override func viewDidLoad() {
        super.viewDidLoad()
        for button in buttons { button.addTarget(self, action: #selector(buttonTapHandler), for: .touchUpInside) }
    }

    @objc func buttonTapHandler(sender:UIButton) {
        let instrument = sender.titleLabel!.text
        performSegue(withIdentifier: "unwindFromInstrToChart", sender: instrument!)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nextVC = segue.destination as? ChartViewController else { return }
        guard let instrument = sender as? String else {return}
        nextVC.category = .instrument
        nextVC.option = "\(instrument.lowercased())/"
    }
}
