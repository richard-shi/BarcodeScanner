//
//  ScannerViewController.swift
//  BarcodeScanner
//
//  Created by Richard Shi on 1/9/17.
//  Copyright © 2017 Richard Shi. All rights reserved.
//

import UIKit

class ScannerViewController: UIViewController, HistoryViewControllerDelegate {

    //MARK: Properties
    
    override var prefersStatusBarHidden: Bool{
        get{
            return true;
        }
    }
    
    //MARK: ViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //MARK: HistoryViewControllerDelegate
    
    func historyViewControllerDidCancel(_ controller: HistoryViewController){
        
    }
    
    func historyViewController(_ controller: HistoryViewController,
                               didFinishAdding checklist: CodeItem){
        
    }
    
}
