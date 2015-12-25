import Foundation
import UIKit
import SafariServices
import Parse
import ParseUI

class SponsorsViewController: PFQueryCollectionViewController {
    private var sponsors: [Company]?
    private let cellIdentifier = "sponsorCell"

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 90, height: 120)
        super.init(collectionViewLayout: layout, className: "UMAD_Sponsor")
        collectionView?.registerClass(PFCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Sponsors"
        collectionView!.backgroundColor = UIColor.whiteColor()
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
        guard let casted = objects as? [UMADSponsor] else {
            return
        }
        var companies = [Company]()
        for sponsor in casted {
            companies.append(sponsor.company)
        }
        self.sponsors = companies
    }


    func companyAtIndexPath(indexPath: NSIndexPath) -> Company? {
        return sponsors?[indexPath.row]
    }

    // MARK: - UICollectionViewController
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
        let webViewController = SFSafariViewController(URL: currentSponsor.websiteURL)
        navigationController?.pushViewController(webViewController, animated: true)
    }

     override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let plainCell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier,
            forIndexPath: indexPath)
        guard let cell = plainCell as? PFCollectionViewCell else {
            return UICollectionViewCell()
        }
        guard let company = companyAtIndexPath(indexPath) else {
            return UICollectionViewCell()
        }
        cell.imageView.file = company.image
        cell.imageView.contentMode = .ScaleAspectFit
        //HAX: Shouldn't really need the placeholder here, but
        //the cells reload very strangely without it
        cell.imageView.image =  UIImage(named: "placeholder")
        cell.imageView.loadInBackground { (image, error) -> Void in
        //This line also seems to be important. Won't load with correct
        //aspect ratio otherwise.
        cell.imageView.contentMode = .ScaleAspectFit
        cell.setNeedsDisplay()
        }
        return cell
    }

    override func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var size = CGSize(width: (view.frame.width/2.3)-10, height: 100)

        return size
    }
}
