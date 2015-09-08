//
//  NavigationController.swift
//  AngramSolver
//
//  Created by Thomas McNally on 2015-09-03.
//  Copyright © 2015 Thomas McNally. All rights reserved.
//

import Foundation

import UIKit

class NavigationController: UINavigationController, UIViewControllerTransitioningDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.translucent = false
        self.navigationBar.barTintColor = UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1)
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationBar.tintColor = UIColor.whiteColor()
    }
}