//
//  EventsViewController.swift
//  uMAD
//
//  Created by Andrew Chun on 1/25/15.
//  Copyright (c) 2015 com.MAD. All rights reserved.
//

import Foundation
import UIKit

class EventsViewController: UIViewController {
    var tableView: UITableView!
    
    
    override init() {
        super.init()
        
        tableView = UITableView(frame: CGRectMake(0, 0, CGRectGetWidth(view.bounds), CGRectGetHeight(view.bounds)), style: UITableViewStyle.Grouped)
        view.addSubview(tableView)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}