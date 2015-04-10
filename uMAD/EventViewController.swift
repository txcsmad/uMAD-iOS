import Foundation
let websiteCellIdentifier = "websiteCell"
class EventViewController: UITableViewController {
    weak var event: Event!
    var eventURL: NSURL?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Session Info"
        view.backgroundColor = UIColor.whiteColor()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier:websiteCellIdentifier)

        event.company.fetchIfNeededInBackgroundWithBlock { (company, error) -> Void in
            let company = company as! Company
            self.eventURL = company.websiteURL
            self.tableView.reloadData()
        }
        if event != nil {
        let headerView = NSBundle.mainBundle().loadNibNamed("EventHeaderView", owner: self, options: nil)[0] as! EventHeaderView
        headerView.sessionDescription.preferredMaxLayoutWidth = 300
        headerView.configure(event)
        tableView.tableHeaderView = headerView
        view.layoutSubviews()
        tableView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.width, height: 20.0) )
        tableView.contentInset = UIEdgeInsetsMake(1.00, 0, 0, 0)
        }
    }

    override func viewWillAppear(animated: Bool) {
    }

    //HAX: We need to wait for the description text to get laid out, then we can adjust
    //the size of frame to extend to just below the text. There should be a better way to
    //accomplish this, but this the best I can seem to do.
    override func viewDidLayoutSubviews() {
        let header = tableView.tableHeaderView as! EventHeaderView
        let newHeight = header.sessionDescription.frame.size.height + header.sessionDescription.frame.origin.y + 20

        if newHeight != tableView.tableHeaderView!.frame.height {
            header.frame.size.height = newHeight
            tableView.tableHeaderView! = header
        }

    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        if eventURL != nil {
            let webViewController = SVWebViewController(URL: event.company.websiteURL)
            webViewController.view.backgroundColor = UIColor.whiteColor()
            PFAnalytics.trackEventInBackground("openedSponsorWebsite", dimensions:nil, block: nil)
            navigationController?.pushViewController(webViewController, animated: true)
        }

    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if eventURL != nil {
            return 1
        }
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(websiteCellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        cell.accessoryType = .DisclosureIndicator
        cell.textLabel?.text = eventURL?.absoluteString
        return cell
    }
}