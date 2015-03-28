import Foundation
let WEBSITE_TABLEVIEW_CELL_IDENTIFIER = "websiteCell"
class EventViewController: UITableViewController {
    let image: UIImage
    weak var event: Event!
    weak var company: Company!

    init(event: Event, company: Company, image: UIImage) {
        self.event = event
        self.company = company
        self.image = image
        super.init(style: .Grouped)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Session Info"
        view.backgroundColor = UIColor.whiteColor()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier:WEBSITE_TABLEVIEW_CELL_IDENTIFIER)
        let headerView = NSBundle.mainBundle().loadNibNamed("EventHeaderView", owner: self, options: nil)[0] as! EventHeaderView
        headerView.configure(event, company: company)
        headerView.sessionThumbnail.image = image
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
        
        var webViewController = SVWebViewController(URL: company.website)
        webViewController.view.backgroundColor = UIColor.whiteColor()
        
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(WEBSITE_TABLEVIEW_CELL_IDENTIFIER, forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = company.website.absoluteString
        return cell
    }
}