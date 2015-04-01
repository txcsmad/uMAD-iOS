import Foundation
let WEBSITE_TABLEVIEW_CELL_IDENTIFIER = "websiteCell"
class EventViewController: UITableViewController {
    weak var event: Event!
    var eventURL: NSURL?
    init(event: Event) {
        self.event = event
        super.init(style: .Grouped)
        event.company.fetchIfNeededInBackgroundWithBlock { (object: PFObject?, error: NSError?) -> Void in
            self.eventURL = self.event.company.websiteURL
            self.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Session Info"
        view.backgroundColor = UIColor.whiteColor()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier:WEBSITE_TABLEVIEW_CELL_IDENTIFIER)
        let headerView = NSBundle.mainBundle().loadNibNamed("EventHeaderView", owner: self, options: nil)[0] as! EventHeaderView
        headerView.configure(event)
        tableView.tableHeaderView = headerView

        view.layoutSubviews()
        tableView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.width, height: 20.0) )
        tableView.contentInset = UIEdgeInsetsMake(1.00, 0, 0, 0)
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
            view.layoutSubviews()
        }

    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        if eventURL != nil {
            let webViewController = SVWebViewController(URL: event.company.websiteURL)
            webViewController.view.backgroundColor = UIColor.whiteColor()
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
        let cell = tableView.dequeueReusableCellWithIdentifier(WEBSITE_TABLEVIEW_CELL_IDENTIFIER, forIndexPath: indexPath) as! UITableViewCell
        cell.accessoryType = .DisclosureIndicator
        cell.textLabel?.text = eventURL?.absoluteString
        return cell
    }
}