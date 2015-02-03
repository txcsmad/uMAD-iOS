//
//  AboutViewController.swift
//  uMAD
//
//  Created by Andrew Chun on 1/30/15.
//  Copyright (c) 2015 com.MAD. All rights reserved.
//

import Foundation

let ABOUT_TABLEVIEW_CELL_IDENTIFIER: String = "ABOUT_TABLEVIEW_CELL_IDENTIFIER"

class AboutViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tableView: UITableView!
    
    override init() {
        super.init()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationItem.title = "About Us"
        
        let madAbout: String  = "We are a student organization at the University of Texas. We are focused on building the UT community by creating a learning environment for all students through ourworkshops, hack nights, conferences, and other awesome events. We want to build the next generation of successful developers, designers, and entrepreneurs."
        
        let umadAbout: String = "The aim of the University of MAD (uMAD) is to provide an environment to learn, develop, and grow over one special weekend with a mixture of technical sessions taught by industry engineers, tech talks, and coding challenges."
        
        let madImage: UIImage = UIImage(named: "mad_logo.png")!
        let imageRatio: CGFloat = CGRectGetWidth(view.bounds) / (madImage.size.width + 100.00)
        
        var madImageView: UIImageView = UIImageView(image: madImage.imageScaledToSize(CGSizeMake(madImage.size.width * imageRatio, madImage.size.height * imageRatio)))
        madImageView.center = CGPointMake(view.center.x, 44.00 + CGRectGetHeight(view.bounds) * 0.05)
        
        let madTitleOriginX: CGFloat = madImageView.frame.origin.x
        let madTitleOriginY: CGFloat = madImageView.frame.origin.y + CGRectGetHeight(madImageView.bounds)
        var madTitleLabel: UILabel = UILabel(frame: CGRectMake(view.center.x - (CGRectGetWidth(madImageView.bounds) * 0.25), madTitleOriginY + 15.00, CGRectGetWidth(madImageView.bounds), 25.00))
        madTitleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: FONT_SIZE + 5)
        madTitleLabel.text = "Who are we?"
        madTitleLabel.sizeToFit()
        madTitleLabel.center = CGPointMake(madImageView.center.x, madTitleLabel.center.y)
        
        let madOriginX: CGFloat = madImageView.frame.origin.x
        let madOriginY: CGFloat = madTitleLabel.frame.origin.y + CGRectGetHeight(madTitleLabel.bounds)
        var madLabel: UILabel = UILabel(frame: CGRectMake(madOriginX, madOriginY + 5.00, CGRectGetWidth(madImageView.bounds), 25.00))
        madLabel.font = UIFont.systemFontOfSize(FONT_SIZE)
        madLabel.textAlignment = NSTextAlignment.Center
        madLabel.text = madAbout
        madLabel.numberOfLines = 0
        madLabel.sizeToFit()
        
        let umadTitleOriginX: CGFloat = madImageView.frame.origin.x
        let umadTitleOriginY: CGFloat = madLabel.frame.origin.y + CGRectGetHeight(madLabel.bounds)
        var umadTitleLabel: UILabel = UILabel(frame: CGRectMake(view.center.x - (CGRectGetWidth(madImageView.bounds) * 0.25), umadTitleOriginY + 15.00, CGRectGetWidth(madImageView.bounds), 25.00))
        umadTitleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: FONT_SIZE + 5)
        umadTitleLabel.text = "What is uMAD?"
        umadTitleLabel.sizeToFit()
        umadTitleLabel.center = CGPointMake(madImageView.center.x, umadTitleLabel.center.y)
        
        let umadOriginX: CGFloat = madImageView.frame.origin.x
        let umadOriginY: CGFloat = umadTitleLabel.frame.origin.y + CGRectGetHeight(umadTitleLabel.bounds)
        var umadLabel: UILabel = UILabel(frame: CGRectMake(umadOriginX, umadOriginY + 5.00, CGRectGetWidth(madImageView.bounds), 25.00))
        umadLabel.font = UIFont.systemFontOfSize(FONT_SIZE)
        umadLabel.textAlignment = NSTextAlignment.Center
        umadLabel.text = madAbout
        umadLabel.numberOfLines = 0
        umadLabel.sizeToFit()
        
        var tableHeaderView: UIView = UIView(frame: CGRectMake(0, 0, CGRectGetWidth(view.bounds), umadLabel.frame.origin.y + CGRectGetHeight(umadLabel.bounds) + 10.00))
        tableHeaderView.backgroundColor = UIColor.whiteColor()
        tableHeaderView.addSubview(madImageView)
        tableHeaderView.addSubview(madTitleLabel)
        tableHeaderView.addSubview(madLabel)
        tableHeaderView.addSubview(umadTitleLabel)
        tableHeaderView.addSubview(umadLabel)
        
        tableView = UITableView(frame: CGRectMake(0, 0, CGRectGetWidth(view.bounds), CGRectGetHeight(view.bounds) - TABBAR_HEIGHT), style: UITableViewStyle.Grouped)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: ABOUT_TABLEVIEW_CELL_IDENTIFIER)
        tableView.tableHeaderView = tableHeaderView
        tableView.backgroundColor = UIColor.whiteColor()
        tableView.delegate = self
        tableView.dataSource =  self
        view.addSubview(tableView)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        var licenseViewController: LicensesViewController = LicensesViewController()
        
        navigationController?.pushViewController(licenseViewController, animated: true)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(ABOUT_TABLEVIEW_CELL_IDENTIFIER, forIndexPath: indexPath) as UITableViewCell
        
        if indexPath.row == 0 {
            cell.textLabel?.text = "Licenses"
        }
        
        return cell
    }
    
}