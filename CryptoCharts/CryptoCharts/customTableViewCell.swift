//
//  customTableViewCell.swift
//  CryptoCharts
//
//  Created by Raymond Hong on 2018-03-10.
//  Copyright © 2018 Raymond Hong. All rights reserved.
//

import Foundation
import UIKit

class customTableViewCell:UITableViewCell {
    @IBOutlet weak var coinImage: UIImageView!
    @IBOutlet weak var coinLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var favButton: UIButton!
    @IBOutlet weak var fullNameLabel: UILabel!
    var mainVc:ViewController!
    
    @IBAction func detectedTapOnStar(_ sender: Any) {
        // Move cell to top of table data
        if (self.favButton.currentImage == #imageLiteral(resourceName: "starBlank")) {
            if let index = self.mainVc.coinObjectArray.index(where: { $0.name == self.coinLabel.text}) {
                var temp = self.mainVc.coinObjectArray[index]
                self.mainVc.coinObjectArray.remove(at: index)
                temp.starImage = #imageLiteral(resourceName: "starFilled")
                self.mainVc.coinObjectArray.insert(temp, at: 0)
            }
            
            //Reload table data and scroll to top of tableview
            DispatchQueue.main.async {
                self.mainVc.tableView.reloadData()
                self.mainVc.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }
            // Remove cell from top of table data
        else {
            //Place cell back to orignal spot from inital sort order load
            if var originalIndex = self.mainVc.appDelegate.coinObjectArrayOriginal.index(where: { $0.name == self.coinLabel.text}) {
                if let alteredIndex = self.mainVc.coinObjectArray.index(where: { $0.name == self.coinLabel.text}) {
                    //Edge case: when coin should be first but others are still favourited
                    //Solution: place at the next avail spot where starImage is not favourited
                    while (self.mainVc.coinObjectArray[originalIndex].starImage == #imageLiteral(resourceName: "starFilled")) {
                        originalIndex += 1;
                    }
                    var temp = self.mainVc.coinObjectArray[alteredIndex]
                    self.mainVc.coinObjectArray.remove(at: alteredIndex)
                    temp.starImage = #imageLiteral(resourceName: "starBlank")
                    
                    //Edge case: account for situatations where first sort order coin is unfavourited
                    if (originalIndex == 1 && temp.sortOrder == 1) {
                        self.mainVc.coinObjectArray.insert(temp, at: 0)
                    } else if (temp.sortOrder == 1) {
                        self.mainVc.coinObjectArray.insert(temp, at: originalIndex-1)
                    } else {
                        self.mainVc.coinObjectArray.insert(temp, at: originalIndex)
                    }
                }
            }
            //Reload table data and scroll to top of tableview
            DispatchQueue.main.async {
                self.mainVc.tableView.reloadData()
                self.mainVc.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }
    }
}

