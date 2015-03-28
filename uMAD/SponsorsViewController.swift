import Foundation
import UIKit

let SPONSORS_CELL_IDENTIFIER = "sponsorCell"
class SponsorsViewController: UICollectionViewController, CompanyDelegate {

    var sponsors = [Company]()

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
        super.viewDidLoad()
        
        navigationItem.title = "Sponsors"
        fetchSponsors()
        collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: SPONSORS_CELL_IDENTIFIER)
        collectionView!.backgroundColor = UIColor.whiteColor()
    }

    private func fetchSponsors(){
        var query = PFQuery(className: "Company")
        query.cachePolicy = .CacheThenNetwork
        query.whereKey("sponsorLevel", greaterThanOrEqualTo: 0)
        query.orderByDescending("sponsorLevel")
        query.findObjectsInBackgroundWithBlock(){
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if error != nil {
                // There was an error
            } else {
                if objects != nil {
                    for object in objects! {
                        let object = object as! PFObject
                        let company = Company(parseReturn: object)
                        company.delegate = self
                        self.sponsors.append(company)
                    }
                }
                self.collectionView!.reloadData()
            }
        }
    }


    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

     override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sponsors.count
    }
    
     override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let currentSponsor = sponsors[indexPath.item]

        UIApplication.sharedApplication().openURL(currentSponsor.website)
    }
    
     override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(SPONSORS_CELL_IDENTIFIER, forIndexPath: indexPath) as! UICollectionViewCell
        
        for view in cell.contentView.subviews{
            view.removeFromSuperview()
        }
        let image = sponsors[indexPath.item].image
        if image != nil {
            let logo = UIImageView(image: image!)
            logo.contentMode = UIViewContentMode.ScaleAspectFit
            logo.frame = CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height)
            cell.contentView.addSubview(logo)
            cell.setNeedsDisplay()
        }

        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var currentSponsor = sponsors[indexPath.item]
        var level = currentSponsor.sponsorLevel
        
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
    func didGetData() {
        collectionView?.reloadData()
    }
}