import Foundation
import CoreLocation

let aboutTableViewCellIdentifier = "aboutcell"

class AboutViewController: UITableViewController {

    init(){
        super.init(style: .Grouped)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewWillAppear(animated: Bool) {

        
    }
    override func viewDidLoad() {
        PFAnalytics.trackEventInBackground("openedAboutTab", dimensions:nil, block: nil)
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationItem.title = "About"

        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: aboutTableViewCellIdentifier)
        let headerView = NSBundle.mainBundle().loadNibNamed("AboutTableHeaderView", owner: self, options: nil)[0] as! AboutTableHeaderView
        let configuration = PFConfig.currentConfig()

        headerView.eventAbout.text = configuration["conferenceAboutText"] as! String?
        headerView.organizationAbout.text = configuration["organizationAboutText"] as! String?
        let geoPoint = configuration["conferenceLocation"] as! PFGeoPoint
        let coordinate = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
        headerView.eventLocation = coordinate
        headerView.eventLocationName = configuration["conferenceLocationName"] as! String?
        headerView.configure()
        tableView.tableHeaderView = headerView
        tableView.backgroundColor = UIColor.whiteColor()
    }

    override func viewWillLayoutSubviews() {
    }

    //HAX: We need to wait for the description text to get laid out, then we can adjust
    //the size of frame to extend to just below the text. There should be a better way to
    //accomplish this, but this the best I can seem to do.
    override func viewDidLayoutSubviews() {
        let header = tableView.tableHeaderView as! AboutTableHeaderView
        let newHeight = header.organizationAbout.frame.size.height + header.organizationAbout.frame.origin.y + 30

        if newHeight != tableView.tableHeaderView!.frame.height {
            header.frame.size.height = newHeight
            tableView.tableHeaderView! = header
            view.layoutSubviews()
        }

    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        var licenseViewController: LicensesViewController = LicensesViewController()
        navigationController?.pushViewController(licenseViewController, animated: true)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(aboutTableViewCellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        cell.accessoryType = .DisclosureIndicator
        if indexPath.row == 0 {
            cell.textLabel?.text = "Licenses"
        }
        
        return cell
    }
    
}