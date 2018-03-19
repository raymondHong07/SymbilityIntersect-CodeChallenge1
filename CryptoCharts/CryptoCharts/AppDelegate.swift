//
//  AppDelegate.swift
//  CryptoCharts
//
//  Created by Raymond Hong on 2018-03-08.
//  Copyright © 2018 Raymond Hong. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var coinObjectArray: [coinObject] = [];
    var requestString = "";
    var requestStringArray:[String] = [];
    let dispatchGroup:DispatchGroup = DispatchGroup();
    var priceDictArray:[NSDictionary] = [];
    var imgDictArray:[NSDictionary] = [];
    var coinObjectArrayOriginal: [coinObject] = [];
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        setCoinData { (error) in
            if (error == "") {
                //Sort array by sortOrder
                self.coinObjectArray = self.coinObjectArray.sorted(by: { $0.sortOrder < $1.sortOrder })
                //Set originalArray to maintain order when fav/unfavouriting
                self.coinObjectArrayOriginal = self.coinObjectArray
                
                //Set dictionary array elements with dummy data
                for _ in 0...self.coinObjectArray.count-1  {
                    let dict:NSDictionary = NSDictionary();
                    self.imgDictArray.append(dict)
                }
                
                //Call to retrieve all price data for coins
                self.setAllPriceData();
                self.setAllImageData();
            } else {
                //Handle Error:
                //Clear all elements of array
                //Reason: viewController will check for empty array to present alert
                self.coinObjectArray.removeAll()
            }
        }
        return true
    }
    
    // MARK: Request functions for hitting endpoints to retrieve data
    func setAllPriceData() {
        if (self.requestStringArray.count > 0) {
            //Set dictionary array elements with dummy data
            self.priceDictArray.removeAll()
            for _ in 0...self.requestStringArray.count-1  {
                let dict:NSDictionary = NSDictionary();
                self.priceDictArray.append(dict)
            }
            
            //Make async requests to retrieve all price data
            for index in 0...self.requestStringArray.count-1  {
                self.setPriceData(coinName: (self.requestStringArray[index]), index:index, completionHandler: { (error) in
                    if (error != "") {
                        //Handle Error:
                        //Clear all elements of array
                        //Reason: viewController will check for empty array to present alert
                        self.priceDictArray.removeAll()
                    }
                })
            }
        }
    }
    
    func setAllImageData() {
        //Get image data for the top 150 coins
        //Reason: reduce the amount of data being processed/downloaded
        for index in 0...150 {
            URLSession.shared.dataTask(with: NSURL(string: String(format:"https://www.cryptocompare.com%@", self.coinObjectArray[index].imageURL))! as URL, completionHandler: { (data, response, error) -> Void in
                
                if error != nil {
                    return
                }
                self.imgDictArray[index] = [self.coinObjectArray[index].name: UIImage(data: data!) ?? #imageLiteral(resourceName: "btc")];
            }).resume()
        }
    }
    
    func setCoinData(completionHandler: @escaping (String) -> ()) {
        let url = URL(string: "https://www.cryptocompare.com/api/data/coinlist/");
        var request = URLRequest(url: url!);
        request.httpMethod = "GET";
        
        let config = URLSessionConfiguration.default;
        let session = URLSession(configuration: config);
        
        let task = session.dataTask(with: request, completionHandler:
        { (data: Data?, response: URLResponse?, error: Error?) in
            if (error != nil) {
                completionHandler((error?.localizedDescription)!);
            }
            if (data != nil) {
                do {
                    if (error != nil) {
                        completionHandler((error?.localizedDescription)!);
                    } else if (data != nil) {
                        var coin:coinObject = coinObject(name: "", coinName: "", imageURL: "", coinPrice:0.0, starImage:#imageLiteral(resourceName: "starBlank"), sortOrder:0, coinImage:#imageLiteral(resourceName: "btc"))
                        let json = try JSONSerialization.jsonObject(with: data!) as? [String: Any]
                        let dict = json!["Data"] as! NSDictionary
                        
                        for key in dict.allKeys {
                            //Set coin data for all coins in json request
                            let innerDict = dict[key] as! NSDictionary;
                            coin.name = innerDict["Name"] as! String;
                            coin.coinName = innerDict["CoinName"] as! String;
                            if (innerDict["ImageUrl"] != nil) {
                                coin.imageURL = innerDict["ImageUrl"] as! String;
                            }
                            coin.sortOrder = Int(innerDict["SortOrder"] as! String)!;
                            self.coinObjectArray.append(coin)
                            
                            //Create/Add coinNames to requestStringArray for price data requests
                            self.requestString += coin.name + ",";
                            if (self.requestString.count >= 285) {
                                self.requestStringArray.append(self.requestString);
                                self.requestString = "";
                            }
                        }
                        self.requestStringArray.append(self.requestString);
                        completionHandler("");
                    }
                } catch let error as NSError {
                    completionHandler((error.localizedDescription));
                }
            }
        })
        task.resume();
    }
    
    func setPriceData(coinName: String, index:Int, completionHandler: @escaping (String) -> ()) {
        let url = URL(string: String(format:"https://min-api.cryptocompare.com/data/pricemulti?fsyms=%@&tsyms=CAD", coinName));
        var request = URLRequest(url: url!);
        request.httpMethod = "GET";
        
        let config = URLSessionConfiguration.default;
        let session = URLSession(configuration: config);
        self.dispatchGroup.enter()
        let task = session.dataTask(with: request, completionHandler:{(data: Data?, response: URLResponse?, error: Error?) in
            if (error != nil) {
                self.dispatchGroup.leave()
                completionHandler((error?.localizedDescription)!);
            }
            if (data != nil) {
                do {
                    if (error != nil) {
                        completionHandler((error?.localizedDescription)!);
                    } else if (data != nil) {
                        let json = try JSONSerialization.jsonObject(with: data!) as? [String: Any]
                        let dict = json! as NSDictionary
                        
                        //Set price dictionary array
                        self.priceDictArray[index] = dict;
                        self.dispatchGroup.leave()
                        completionHandler("");
                    }
                } catch let error as NSError {
                    self.dispatchGroup.leave()
                    completionHandler((error.localizedDescription));
                }
            }
        })
        task.resume();
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

