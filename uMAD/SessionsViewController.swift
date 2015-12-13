//
//  SessionsViewController.swift
//  uMAD
//
//  Created by Jesse Tipton on 12/11/15.
//  Copyright © 2015 com.MAD. All rights reserved.
//

import Parse
import ParseUI

class SessionsViewController: PFQueryTableViewController {

    private let cellIdentifier = "SessionCell"
    
    // MARK: - PFQueryTableViewController

    override func queryForTable() -> PFQuery {
        let query = Session.query()!
        query.cachePolicy = .CacheThenNetwork
        
        query.includeKey("company")
        query.orderByAscending("startTime")
        
        return query
    }
    
    // MARK: - UITableViewController
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! SessionTableViewCell
        
        let session = objectAtIndexPath(indexPath) as! Session
        cell.configureForSession(session)
        
        return cell
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Sessions"
        
        tableView.registerClass(SessionTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.rowHeight = 64
        tableView.separatorInset = UIEdgeInsetsZero
    }
    
}
