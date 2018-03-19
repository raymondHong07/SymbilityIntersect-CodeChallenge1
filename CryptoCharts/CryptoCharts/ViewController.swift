//
//  ViewController.swift
//  CryptoCharts
//
//  Created by Raymond Hong on 2018-03-08.
//  Copyright © 2018 Raymond Hong. All rights reserved.
//

import UIKit

struct coinObject {
    var name:String;
    var coinName:String;
    var imageURL:String;
    var coinPrice:Float;
    var starImage:UIImage;
    var sortOrder:Int;
    var coinImage:UIImage;
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var coinObjectArray: [coinObject] = [];
    let cellReuseIdentifier = "cell"
    var refreshControl:UIRefreshControl!
    let dispatchGroup:DispatchGroup = DispatchGroup();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.coinObjectArray = self.appDelegate.coinObjectArray;
        self.initTable()
        
        appDelegate.dispatchGroup.notify(queue: .main) {
            if (self.appDelegate.priceDictArray.count > 0 && self.appDelegate.coinObjectArray.count > 0) {
                //reload table data when all price data requests are finished
                self.tableView.reloadData();
            } else {
                //Display error if no data was retrieved
                let alert = UIAlertController(title: "Error", message: "Could not make server requests please check network on device", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: tableView delegate methods and initializers
    func initTable() {
        //Initialize table delegates
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        //Initialize customTableViewCell nib
        let nib = UINib(nibName: "tableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "cell")
        
        //Initialize refresh control for tableview
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action:#selector(ViewController.handleRefresh(_:)),for: UIControlEvents.valueChanged)
        self.refreshControl.tintColor = UIColor.gray
        
        //Set tableview properties
        self.tableView.addSubview(self.refreshControl)
        self.tableView.allowsSelection = false
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        //Get price data
        appDelegate.setAllPriceData();
        
        //Reload table data once all price data has been retrieved
        appDelegate.dispatchGroup.notify(queue: .main, execute: {
            if (self.appDelegate.priceDictArray.count > 0 && self.appDelegate.coinObjectArray.count > 0) {
                self.tableView.reloadData();
            } else {
                //Display error if no data was retrieved
                let alert = UIAlertController(title: "Error", message: "Could not make server requests please check network on device", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            refreshControl.endRefreshing()
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.coinObjectArray.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Initialize custom cell
        let cell:customTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! customTableViewCell
        cell.mainVc = self;
        
        //Set cell data
        cell.fullNameLabel.text = self.coinObjectArray[indexPath.row].coinName;
        cell.coinLabel.text = self.coinObjectArray[indexPath.row].name;
        cell.favButton.setImage(self.coinObjectArray[indexPath.row].starImage, for: .normal)
        
        //Set price data
        cell.coinImage.image = self.coinObjectArray[indexPath.row].coinImage
        cell.priceLabel.text = "Currently Unavailable"
        for dict in self.appDelegate.priceDictArray {
            if dict.value(forKey: self.coinObjectArray[indexPath.row].name) != nil {
                let innerDict = dict[self.coinObjectArray[indexPath.row].name] as! NSDictionary;
                let price = innerDict["CAD"] as! Float
                cell.priceLabel.text = String(format: "$%f", price)
            }
        }
        
        //Set image data for top 150 coins
        for dict in self.appDelegate.imgDictArray {
            if dict.value(forKey: self.coinObjectArray[indexPath.row].name) != nil {
                let image = dict[self.coinObjectArray[indexPath.row].name];
                cell.coinImage.image = (image as! UIImage)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

