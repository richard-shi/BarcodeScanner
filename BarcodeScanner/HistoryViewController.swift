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
    var dataModel:DataModel!
    
    //MARK: Table View Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel.codeItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = makeCell(for: tableView)
        
        //Display code data
        let item = dataModel.codeItems[indexPath.row]
        cell.textLabel?.text = "\(item.type):\(item.content)"
        
        //Display code timestamp on subtitle
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        cell.detailTextLabel?.text = dateFormatter.string(from: item.timestamp)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCellEditingStyle,
                            forRowAt indexPath: IndexPath) {
        dataModel.codeItems.remove(at: indexPath.row)
        
        let indexPaths = [indexPath]
        tableView.deleteRows(at: indexPaths, with: .automatic)
    }

    
    func makeCell(for tableView:UITableView)->UITableViewCell{
        let cellIdentifier = "HistoryCell"
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier){
            return cell
        } else{
            return UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }
    }
    
    //MARK: Actions
    @IBAction func back(){
        delegate?.historyViewControllerDidReturn(self)
    }
}
