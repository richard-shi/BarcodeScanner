//
//  HistoryTableViewController.swift
//  BarcodeScanner
//
//  Created by Richard Shi on 1/9/17.
//  Copyright © 2017 Richard Shi. All rights reserved.
//

import UIKit

protocol HistoryViewControllerDelegate: class {
    func historyViewControllerDidReturn(_ controller: HistoryViewController)
    func historyViewController(_ controller: HistoryViewController,
                                  didFinishEditing codeItem: CodeItem)
}

class HistoryViewController: UITableViewController {
    weak var delegate:HistoryViewControllerDelegate?
    weak var dataModel:DataModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel.codeItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCodeItemCell", for: indexPath)
        let item = dataModel.codeItems[indexPath.row]
        
        let label = cell.viewWithTag(1000) as! UILabel
        label.text = item.content
        
        return cell
    }
    
    @IBAction func back(){
        delegate?.historyViewControllerDidReturn(self)
    }
}
