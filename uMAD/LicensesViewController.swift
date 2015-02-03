//
//  LicensesViewController.swift
//  uMAD
//
//  Created by Andrew Chun on 1/31/15.
//  Copyright (c) 2015 com.MAD. All rights reserved.
//

import Foundation

let STTWITTER_LICENSE: String = "Copyright (c) 2012-2014, Nicolas Seriot\nAll rights reserved.\n\nRedistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:\n\n* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.\n* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.\n* Neither the name of the Nicolas Seriot nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.\n\nTHIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS \"AS IS\" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."

let SVWEBVIEWCONTROLLER_LICENSE: String = "Copyright (c) 2011 Sam Vermette\n\nPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."

let UIIMAGERESIZE_LICENSE: String = "Copyright (c) 2013 Marc Charbonneau\n\nPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: \n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. \n\nTHE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."

let FLATICON_LICENSE: String = "Calender Icon\nIcon made by Freepik, http://www.freepik.com, from www.flaticon.com is licensed under CC BY 3.0, http://creativecommons.org/licenses/by/3.0/\n\nTwitter Icon\nIcon made by Linh Pham, http://linhpham.me/miu, from www.flaticon.com is licensed under CC BY 3.0, http://creativecommons.org/licenses/by/3.0/\n\nSponsors Icon\nIcon made by Freepik, http://www.freepik.com, from www.flaticon.com is licensed under CC BY 3.0, http://creativecommons.org/licenses/by/3.0/\n\nAbout Us Icon\nIcon made by FreePik, http://www.freepik.com, from www.flaticon.com is licensed under CC BY 3.0, http://creativecommons.org/licenses/by/3.0/"

class LicensesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tableView: UITableView!
    
    override init() {
        super.init()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Licenses"
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.tableView = UITableView(frame: CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)))
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "LICENSE_TABLEVIEW_CELL")
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.addSubview(self.tableView)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        var licenseName: String
        var licenseDetails: String
        
        switch indexPath.row {
            case 0:
                licenseName = "STTwitter"
                licenseDetails = STTWITTER_LICENSE
            case 1:
                licenseName = "SVWebViewController"
                licenseDetails = SVWEBVIEWCONTROLLER_LICENSE
            case 2:
                licenseName = "UIImage+Resize"
                licenseDetails = UIIMAGERESIZE_LICENSE
            case 3:
                licenseName = "FlatIcon"
                licenseDetails = FLATICON_LICENSE
            default:
                fatalError("Unidentifiable cell selected at indexPath.row: \(indexPath.row)")
        }
        
        var licenseViewController: LicenseViewController = LicenseViewController(licenseName: licenseName, licenseDetails: licenseDetails)
        self.navigationController?.pushViewController(licenseViewController, animated: true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("LICENSE_TABLEVIEW_CELL", forIndexPath: indexPath) as UITableViewCell
        
        println(indexPath.row)
        
        switch indexPath.row {
            case 0:
                cell.textLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: FONT_SIZE + 3)
                cell.textLabel?.text = "STTwitter"
            case 1:
                cell.textLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: FONT_SIZE + 3)
                cell.textLabel?.text = "SVWebViewController"
            case 2:
                cell.textLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: FONT_SIZE + 3)
                cell.textLabel?.text = "UIImage+Resize"
            case 3:
                cell.textLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: FONT_SIZE + 3)
                cell.textLabel?.text = "FlatIcon"
            default:
                fatalError("Unidentifiable indexPath.row value: \(indexPath.row)")
        }
        
        return cell;
    }
    
}