import Foundation
import UIKit

let sponsorCellIdentifier = "sponsorCell"
class SponsorsViewController: UICollectionViewController {

    var sponsors: [Company]?

    init(){
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 90, height: 120)
        super.init(collectionViewLayout: layout)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        PFAnalytics.trackEventInBackground("openedSponsorsTab", dimensions:nil, block: nil)
        super.viewDidLoad()
        
        navigationItem.title = "Sponsors"
        collectionView!.registerClass(PFCollectionViewCell.self, forCellWithReuseIdentifier: sponsorCellIdentifier)
        collectionView!.backgroundColor = UIColor.whiteColor()
        fetchSponsors()
    }

    private func fetchSponsors(){
        var query = PFQuery(className: "Company")
        query.cachePolicy = .CacheThenNetwork
        query.whereKey("sponsorLevel", greaterThanOrEqualTo: 0)
        query.orderByDescending("sponsorLevel")
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error != nil {
                return
                // There was an error
            }
            self.sponsors = objects as! [Company]?
            self.collectionView!.reloadData()
        }
    }


    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

     override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if sponsors != nil {
            return sponsors!.count
        }
        return 0
    }
    
     override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let currentSponsor = sponsors![indexPath.item]
        PFAnalytics.trackEventInBackground("openedSponsorWebsite", dimensions:nil, block: nil)
        UIApplication.sharedApplication().openURL(currentSponsor.websiteURL)
    }
    
     override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(sponsorCellIdentifier, forIndexPath: indexPath) as! PFCollectionViewCell
        let company = sponsors![indexPath.item]
        cell.imageView.file = company.image
        cell.imageView.contentMode = .ScaleAspectFit
        //HAX: Shouldn't really need the placeholder here, but 
        //the cells reload very strangely without it
        cell.imageView.image =  UIImage(named: "placeholder")
        cell.imageView.loadInBackground { (image, error) -> Void in
            //This line also seems to be important. Won't load with correct
            //aspect ration otherwise.
            cell.imageView.contentMode = .ScaleAspectFit
            cell.setNeedsDisplay()
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let currentSponsor = sponsors![indexPath.item]
        let level = currentSponsor.sponsorLevel
        
        var size : CGSize
        
        switch level{
        case 0:
            size = CGSize(width: (view.frame.width/2.3)-10, height: 100)
        case 1:
            size = CGSize(width: (view.frame.width/2.3)-10, height: 100)
        case 2:
            size = CGSize(width: view.frame.width - 20, height: 150)
        default:
            size = CGSize(width: (view.frame.width/2.3)-10, height: 100)
            
        }
        return size
    }
}