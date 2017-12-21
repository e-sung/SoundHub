//
//  DocumentBrowserViewController.swift
//  Soundhub
//
//  Created by 류성두 on 2017. 11. 29..
//  Copyright © 2017년 류성두. All rights reserved.
//

import UIKit
import AVFoundation
import ActionSheetPicker_3_0

class DocumentBrowserViewController: UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        browserUserInterfaceStyle = .dark
        view.tintColor = .orange

    }
    
    @objc func onDoneButtonHandler(sender:UIBarButtonItem){
       self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onDoneButtonHandler))
        self.additionalTrailingNavigationBarButtonItems = [cancelButton]
        if presentingViewController == nil {
            performSegue(withIdentifier: "startingSegue", sender: nil)
        }
    }
    
    
    // MARK: UIDocumentBrowserViewControllerDelegate
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        let newDocumentURL: URL? = nil
        
        // Set the URL for the new document here. Optionally, you can present a template chooser before calling the importHandler.
        // Make sure the importHandler is always called, even if the user cancels the creation request.
        if newDocumentURL != nil {
            importHandler(newDocumentURL, .move)
        } else {
            importHandler(nil, .none)
        }
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentURLs documentURLs: [URL]) {
        guard let sourceURL = documentURLs.first else { return }
        
        // Present the Document View Controller for the first document that was picked.
        // If you support picking multiple items, make sure you handle them all.
        presentDocument(at: sourceURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
        // Present the Document View Controller for the new newly created document
        presentDocument(at: destinationURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) {
        // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
    }
    
    // MARK: Document Presentation
    
    func presentDocument(at documentURL: URL) {
        print(documentURL)
        let storyBoard = UIStoryboard(name: "Entry", bundle: nil)
        let audioUploadVC = storyBoard.instantiateViewController(withIdentifier: "DocumentViewController") as! AudioUploadViewController
        audioUploadVC.audioURL = documentURL

        
        ActionSheetStringPicker.show(withTitle: "어떤 악기인가요?", rows: Instrument.cases, initialSelection: 0, doneBlock: { (picker, row, result) in
            audioUploadVC.instrument = Instrument.cases[row]
            ActionSheetStringPicker.show(withTitle: "어떤 장르인가요?", rows: Genre.cases, initialSelection: 0, doneBlock: { (picker, row, result) in
                audioUploadVC.genre = Genre.cases[row]
                self.present(audioUploadVC, animated: true, completion: nil)
            }, cancel: { (picker) in
            }, origin: self.view)
        }, cancel: { (picker) in
        }, origin: self.view)
    }
}


