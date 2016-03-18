//
//  ViewController.swift
//  FirstAPP
//
//  Created by LRF on 16/1/5.
//  Copyright © 2016年 LRF. All rights reserved.
//

import UIKit

import FirstMixed

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        var swiftView = SwiftView(frame: CGRectMake(0, 0, 50, 50))
        self.view .addSubview(swiftView)
        
        var mixedView = MixedView(frame: CGRectMake(50, 0, 50, 50))
        self.view.addSubview(mixedView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

