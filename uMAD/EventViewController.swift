import Foundation

class EventViewController: UITableViewController {
    var image: UIImage!
    var event: Event!

    init(image: UIImage, event: Event) {
        self.event = event
        self.image = image
        super.init(style: .Grouped)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Session Info"
        view.backgroundColor = UIColor.whiteColor()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier:"WEBSITE_TABLEVIEW_CELL")
        let headerView = NSBundle.mainBundle().loadNibNamed("EventHeaderView", owner: self, options: nil)[0] as! EventHeaderView
        headerView.configureFromEvent(event)
        headerView.sessionThumbnail.image = image
        headerView.sizeToFit()
        headerView.layoutSubviews()
        //headerView.frame.size = CGSize(width: headerView.frame.size.width, height: 10.0)
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.width, height: 50.0) )
        tableView.contentInset = UIEdgeInsetsMake(1.00, 0, 0, 0)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        var webViewController = SVWebViewController(URL: self.event.companyWebsite)
        webViewController.view.backgroundColor = UIColor.whiteColor()
        
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("WEBSITE_TABLEVIEW_CELL", forIndexPath: indexPath) as! UITableViewCell
        
        cell.textLabel?.text = event.companyWebsite?.absoluteString
        
        return cell
    }
}