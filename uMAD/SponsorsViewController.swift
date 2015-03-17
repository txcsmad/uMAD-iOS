import Foundation
import UIKit

let SPONSORS_CELL_IDENTIFIER = "sponsorCell"
class SponsorsViewController: UICollectionViewController {

    var sponsors = [PFObject]()
    var images = [UIImage?]()

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
        var query = PFQuery(className: "Sponsors")
        query.whereKey("sponsorLevel", greaterThanOrEqualTo: 0)
        query.orderByDescending("sponsorLevel")
        query.findObjectsInBackgroundWithBlock{(objects: [AnyObject]!, error: NSError!) -> Void in
            if error != nil {
                // There was an error
            } else {
                // objects has all the Posts the current user liked.
                self.sponsors = objects as! [PFObject]
                self.storeImages()
                self.collectionView!.reloadData()
            }
        }
    }
    
    func storeImages(){
        self.images = [UIImage?](count: sponsors.count, repeatedValue: nil)

        for var i = 0; i < sponsors.count; i++ {
            var currentSponsor = sponsors[i]
            let indexForBlock = i
            var imageFile = currentSponsor["companyImage"] as! PFFile
            imageFile.getDataInBackgroundWithBlock{
                (imageData: NSData!, error: NSError!) in
                if error != nil {
                    return
                }
                let image = UIImage(data:imageData)
                self.images[indexForBlock] = image
                self.collectionView!.reloadItemsAtIndexPaths([NSIndexPath(forItem: indexForBlock, inSection: 0)])
            }
        }

    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

     override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
     override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var currentSponsor: PFObject = sponsors[indexPath.item]
        var webLink = currentSponsor["companyWebsite"] as! String

        UIApplication.sharedApplication().openURL(NSURL(string: webLink)!)
    }
    
     override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(SPONSORS_CELL_IDENTIFIER, forIndexPath: indexPath) as! UICollectionViewCell
        
        for view in cell.contentView.subviews{
            view.removeFromSuperview()
        }
        if images[indexPath.item] != nil {
        let logo = UIImageView(image: images[indexPath.item])
        logo.contentMode = UIViewContentMode.ScaleAspectFit
        logo.frame = CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height)
        cell.contentView.addSubview(logo)
        cell.setNeedsDisplay()
        }

        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var currentSponsor = sponsors[indexPath.item]
        var level = currentSponsor["sponsorLevel"] as! Int
        
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