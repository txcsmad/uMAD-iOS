import UIKit
import CoreLocation
import Parse

class AboutViewController: UITableViewController {

    private let cellIdentifier = "aboutcell"

    init() {
        super.init(style: .Grouped)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    override init(style: UITableViewStyle) {
        super.init(style: .Grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewWillAppear(animated: Bool) {

    }
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.whiteColor()
        navigationItem.title = "About"

        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.estimatedRowHeight = 300
        automaticallyAdjustsScrollViewInsets = true
        tableView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.width, height: 20.0) )
        tableView.tableHeaderView = nil
        tableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0)

        tableView.backgroundColor = UIColor.whiteColor()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.row == 1
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0:
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
        default:
            print("Unknow index")
        }

    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch indexPath.row {

        case 0:
            let configuration = PFConfig.currentConfig()
            let nib = NSBundle.mainBundle().loadNibNamed("AboutTableHeaderView", owner: self, options: nil)[0]
            guard let headerView = nib as? AboutTableHeaderView else {
                return UITableViewCell()
            }
            headerView.eventAbout.text = configuration["conferenceAboutText"] as? String
            headerView.organizationAbout.text = configuration["organizationAboutText"] as? String

            if let geoPoint = configuration["conferenceLocation"] as? PFGeoPoint {
                let coordinate = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
                headerView.eventLocation = coordinate
                headerView.eventLocationName = configuration["conferenceLocationName"] as? String
            }
            headerView.configure()
            cell = headerView
        default:
            cell = UITableViewCell()
        }

        return cell
    }

}
