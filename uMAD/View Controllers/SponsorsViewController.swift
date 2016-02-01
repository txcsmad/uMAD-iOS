import Foundation
import UIKit
import SafariServices
import Parse
import ParseUI

class SponsorsViewController: PFQueryCollectionViewController {

    private let cellIdentifier = "sponsorCell"
    private var sponsors: [UMADSponsor]?
    private var sectionedSponsors: [[UMADSponsor]]?
    // MARK: - Initializers

    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout(), className: "UMAD_Sponsor")
        collectionView?.registerClass(PFCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        navigationItem.title = "Partners"
        pullToRefreshEnabled = false
    }

    required convenience init(coder aDecoder: NSCoder) {
        self.init()
    }

    // MARK: - SponsorsViewController

    private func companyAtIndexPath(indexPath: NSIndexPath) -> Company? {
        //let sponsorAtIndexPath = sectionedSponsors?[indexPath.section][indexPath.item]
        let sponsorAtIndexPath = sponsors?[indexPath.item]
        return sponsorAtIndexPath?.company
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

    override func objectsDidLoad(error: NSError?) {
        super.objectsDidLoad(error)
        guard error == nil,
            let sponsors = objects as? [UMADSponsor] else {
            return
        }

        self.sponsors = sponsors.sort {$1.sponsorLevel < $0.sponsorLevel}
        sectionedSponsors = self.sponsors!.createSectionedRepresentation()
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFCollectionViewCell? {

        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as? PFCollectionViewCell,
            company = companyAtIndexPath(indexPath) else {
            return nil
        }
        cell.imageView.image = UIImage(named: "placeholder")
        cell.imageView.file = company.image
        cell.imageView.contentMode = .ScaleAspectFit
        cell.imageView.loadInBackground()
        return cell
    }

    // MARK: - UICollectionViewDelegate

     override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let selectedCompany = companyAtIndexPath(indexPath) else {
            return
        }
        let safariViewController = SFSafariViewController(URL: selectedCompany.websiteURL)
        safariViewController.view.tintColor = Config.tintColor
        presentViewController(safariViewController, animated: true, completion: nil)
    }


    // MARK: - UICollectionViewDelegateFlowLayout

    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 15, left: 20, bottom: 15, right: 20)
    }

    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            guard let sponsor = sponsors?[indexPath.item] else {
                return CGSizeZero
            }
            let nToRow: Int
            switch sponsor.sponsorLevel {
            case .Gold:
                nToRow = 1
                break
            case .Silver:
                nToRow = 2
                break
            case .Bronze:
                nToRow = 3
                break
            }
            return CGSize(width: (view.frame.width / 2.3) - 10, height: 100)
    }

}
