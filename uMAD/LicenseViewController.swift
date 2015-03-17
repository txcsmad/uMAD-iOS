import Foundation

class LicenseViewController: UIViewController {
    var licenseName: String!
    var licenseDetails: String!
    
    required init(licenseName: String, licenseDetails: String) {
        super.init(nibName: nil, bundle: nil)
        
        self.licenseName = licenseName
        self.licenseDetails = licenseDetails
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        
        var nameLabel: UILabel = UILabel(frame: CGRectMake(CGRectGetWidth(self.view.bounds) * 0.05, CGRectGetHeight(self.view.bounds) * 0.02, CGRectGetWidth(self.view.bounds) * 0.90, 20.00))
        nameLabel.font = UIFont(name: "HelveticaNeue-Bold", size: FONT_SIZE + 3)
        nameLabel.text = self.licenseName
        nameLabel.sizeToFit()

        var detailsLabel: UILabel = UILabel(frame: CGRectMake(CGRectGetWidth(self.view.bounds) * 0.05, CGRectGetHeight(nameLabel.bounds) + nameLabel.frame.origin.y + CGRectGetHeight(self.view.bounds) * 0.02, CGRectGetWidth(self.view.bounds) * 0.90, 20.00))
        detailsLabel.font = UIFont.systemFontOfSize(FONT_SIZE - 3)
        detailsLabel.text = self.licenseDetails
        detailsLabel.numberOfLines = 0
        detailsLabel.sizeToFit()
        
        var scrollView: UIScrollView = UIScrollView(frame: CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(view.bounds) - 50))
        scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds), detailsLabel.frame.origin.y + CGRectGetHeight(detailsLabel.bounds))
        self.view.addSubview(scrollView)
        scrollView.addSubview(nameLabel)
        scrollView.addSubview(detailsLabel)
    }
}