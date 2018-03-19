//
//  SplashScreenViewController.swift
//  CryptoCharts
//
//  Created by Raymond Hong on 2018-03-17.
//  Copyright © 2018 Raymond Hong. All rights reserved.
//

import Foundation
import UIKit

class SplashScreenViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        perform(#selector(showMainView), with: nil, afterDelay: 3.5)
    }
    
    @objc func showMainView() {
        performSegue(withIdentifier: "showNavController", sender: self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

