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