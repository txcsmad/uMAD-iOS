//
//  SponsorsViewController.swift
//  uMAD
//
//  Created by Andrew Chun on 1/25/15.
//  Copyright (c) 2015 com.MAD. All rights reserved.
//

import Foundation
import UIKit

class SponsorsViewController: UIViewController,UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    var collectionView: UICollectionView?
    var sponsorCount = 0
    var sponsors : [PFObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Sponsors"
        
        // Do any additional setup after loading the view, typically from a nib.
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 90, height: 120)
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView!.dataSource = self
        collectionView!.delegate = self
        collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView!.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.collectionView!)
        
        var query = PFQuery(className: "Sponsors")
        query.orderByDescending("sponsorLevel")
        query.findObjectsInBackgroundWithBlock{(objects: [AnyObject]!, error: NSError!) -> Void in
            if error != nil {
            // There was an error
            } else {
            // objects has all the Posts the current user liked.
                self.sponsors = objects as [PFObject]
                self.sponsorCount = self.sponsors.count
                self.collectionView?.reloadData()
            }
        }
    
    
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sponsorCount
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as UICollectionViewCell
        var currentSponsor: PFObject = sponsors[indexPath.item]
        var imageFile: PFFile = currentSponsor["companyImage"] as PFFile
        
        imageFile.getDataInBackgroundWithBlock{
            (imageData: NSData!, error: NSError!) -> Void in
            if error == nil {
                let image = UIImage(data:imageData)
                let logo = UIImageView(image: image)
                logo.frame = CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height)
                cell.addSubview(logo)
                cell.setNeedsDisplay()
            }
        }
        return cell
    }
    
    
    
}