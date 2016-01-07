import Foundation
import UIKit
import SafariServices
import Parse
import ParseUI

class SponsorsViewController: PFQueryCollectionViewController {
    
    private let cellIdentifier = "sponsorCell"

    // MARK: - Initializers
    
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout(), className: "UMAD_Sponsor")
        collectionView?.registerClass(PFCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        navigationItem.title = "Sponsors"
    }

    required convenience init(coder aDecoder: NSCoder) {
        self.init()
    }

    // MARK: - SponsorsViewController
    
    private func companyAtIndexPath(indexPath: NSIndexPath) -> Company {
        let sponsors = objects as! [UMADSponsor]
        let sponsorAtIndexPath = sponsors[indexPath.row]
        return sponsorAtIndexPath.company
    }
    
    // MARK: - PFQueryCollectionViewController

    override func queryForCollection() -> PFQuery {
        let query = UMADSponsor.query()!
        query.cachePolicy = .CacheThenNetwork
        query.includeKey("company")
        if let currentUMAD = AppDelegate.currentUMAD {
            query.whereKey("umad", equalTo: currentUMAD)
        }
        return query
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFCollectionViewCell? {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as? PFCollectionViewCell
        cell?.imageView.image = UIImage(named: "placeholder")
        cell?.imageView.file = companyAtIndexPath(indexPath).image
        cell?.imageView.loadInBackground()
        return cell
    }
    
    // MARK: - UICollectionViewDelegate

     override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let selectedCompany = companyAtIndexPath(indexPath)
        let safariViewController = SFSafariViewController(URL: selectedCompany.websiteURL)
        presentViewController(safariViewController, animated: true, completion: nil)
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: (view.frame.width / 2.3) - 10, height: 100)
    }
    
}
