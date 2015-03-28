import Foundation

let ABOUT_TABLEVIEW_CELL_IDENTIFIER: String = "aboutcell"

class AboutViewController: UITableViewController {

    init(){
        super.init(style: .Grouped)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationItem.title = "About Us"

        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: ABOUT_TABLEVIEW_CELL_IDENTIFIER)
        let headerView = NSBundle.mainBundle().loadNibNamed("AboutTableHeaderView", owner: self, options: nil)[0] as! UIView
        tableView.tableHeaderView = headerView
        tableView.backgroundColor = UIColor.whiteColor()
    }

    //HAX: We need to wait for the description text to get laid out, then we can adjust
    //the size of frame to extend to just below the text. There should be a better way to
    //accomplish this, but this the best I can seem to do.
    override func viewDidLayoutSubviews() {
        let header = tableView.tableHeaderView as! AboutTableHeaderView
        let newHeight = header.umadAbout.frame.size.height + header.umadAbout.frame.origin.y + 50

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
        var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(ABOUT_TABLEVIEW_CELL_IDENTIFIER, forIndexPath: indexPath) as! UITableViewCell
        
        if indexPath.row == 0 {
            cell.textLabel?.text = "Licenses"
        }
        
        return cell
    }
    
}