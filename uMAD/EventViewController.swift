import Foundation
let websiteCellIdentifier = "websiteCell"
class EventViewController: UITableViewController {
    weak var event: Event!
    var eventURL: NSURL?

    init(){
        super.init(style: .Grouped)
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    override init(style: UITableViewStyle) {
        super.init(style: .Grouped)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Session Info"
        view.backgroundColor = UIColor.whiteColor()

        event.company.fetchIfNeededInBackgroundWithBlock { (company, error) -> Void in
            let company = company as! Company
            self.eventURL = company.websiteURL
            self.tableView.reloadData()
        }
        tableView.estimatedRowHeight = 200
        automaticallyAdjustsScrollViewInsets = true
        tableView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.width, height: 20.0) )
        tableView.tableHeaderView = nil
        tableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0)
    }

    override func viewWillAppear(animated: Bool) {
    }
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.row == 1
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0{
             tableView.deselectRowAtIndexPath(indexPath, animated: false)
        } else {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            if eventURL != nil {
                let webViewController = SVWebViewController(URL: event.company.websiteURL)
                webViewController.view.backgroundColor = UIColor.whiteColor()
                PFAnalytics.trackEventInBackground("openedSponsorWebsite", dimensions:nil, block: nil)
                navigationController?.pushViewController(webViewController, animated: true)
            }
        }

    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if eventURL != nil {
            return 2
        }
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch indexPath.row {
        case 0:
            let headerView = NSBundle.mainBundle().loadNibNamed("EventHeaderView", owner: self, options: nil)[0] as! EventHeaderView
            headerView.sessionDescription.preferredMaxLayoutWidth = 300
            headerView.configure(event)
            cell = headerView

        case 1:
            cell = UITableViewCell()
            cell.accessoryType = .DisclosureIndicator
            cell.textLabel?.text = eventURL?.absoluteString

        default:
            cell = UITableViewCell()
        }
        return cell
    }
}