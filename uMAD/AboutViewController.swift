import Foundation
import CoreLocation

let aboutTableViewCellIdentifier = "aboutcell"

class AboutViewController: UITableViewController {

    init(){
        super.init(style: .Grouped)
    }
    override init!(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    override init(style: UITableViewStyle) {
        super.init(style: .Grouped)
    }

    required init!(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    override func viewWillAppear(animated: Bool) {

        
    }
    override func viewDidLoad() {
        PFAnalytics.trackEventInBackground("openedAboutTab", dimensions:nil, block: nil)
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        navigationItem.title = "About"

        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: aboutTableViewCellIdentifier)
        tableView.estimatedRowHeight = 300
        automaticallyAdjustsScrollViewInsets = true
        tableView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.width, height: 20.0) )
        tableView.tableHeaderView = nil
        tableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0)

        tableView.backgroundColor = UIColor.whiteColor()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.row == 1
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0:
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
        case 1:
            tableView.deselectRowAtIndexPath(indexPath, animated: true)

            var licenseViewController: LicensesViewController = LicensesViewController()
            navigationController?.pushViewController(licenseViewController, animated: true)
        default:
            println("Unknow index")
        }

    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch indexPath.row {

        case 0:
            let configuration = PFConfig.currentConfig()
            let headerView = NSBundle.mainBundle().loadNibNamed("AboutTableHeaderView", owner: self, options: nil)[0] as! AboutTableHeaderView
            headerView.eventAbout.text = configuration["conferenceAboutText"] as! String?
            headerView.organizationAbout.text = configuration["organizationAboutText"] as! String?
            let geoPoint = configuration["conferenceLocation"] as! PFGeoPoint?
            if geoPoint != nil {
                let coordinate = CLLocationCoordinate2D(latitude: geoPoint!.latitude, longitude: geoPoint!.longitude)
                headerView.eventLocation = coordinate
                headerView.eventLocationName = configuration["conferenceLocationName"] as! String?
            }
            headerView.configure()
            cell = headerView
        case 1:
            cell = tableView.dequeueReusableCellWithIdentifier(aboutTableViewCellIdentifier, forIndexPath: indexPath) as! UITableViewCell
            cell.accessoryType = .DisclosureIndicator
            cell.textLabel?.text = "Licenses"
        default:
            cell = UITableViewCell()
        }
        
        return cell
    }
    
}