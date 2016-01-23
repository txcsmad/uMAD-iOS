import UIKit
import CoreLocation
import Parse
import MapKit
import SafariServices

class AboutViewController: UIViewController {
    @IBOutlet var eventAbout: UILabel!
    @IBOutlet var organizationAbout: UILabel!
    @IBOutlet var organizationImage: UIImageView!
    @IBOutlet var eventMap: MKMapView!

    var eventLocation: CLLocationCoordinate2D?
    var eventLocationName: String?
    var organizationURL: NSURL?


    init() {
        super.init(nibName: "AboutView", bundle: nil)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.whiteColor()
        navigationItem.title = "About"

        let configuration = PFConfig.currentConfig()
        eventAbout.text = configuration["conferenceAboutText"] as? String
        organizationAbout.text = configuration["organizationAboutText"] as? String

        if let urlString = configuration["organizationURL"] as? String,
            let url = NSURL(string: urlString) {
                organizationURL = url
        }


        if let geoPoint = configuration["conferenceLocation"] as? PFGeoPoint {
            let coordinate = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
            eventLocation = coordinate
            eventLocationName = configuration["conferenceLocationName"] as? String
        }
        configure()
    }


    func configure() {
        if let location = eventLocation {
            eventMap.hidden = false
            let viewRegion = MKCoordinateRegionMakeWithDistance(location, 500, 500)
            let adjustedRegion = eventMap.regionThatFits(viewRegion)
            eventMap.setRegion(adjustedRegion, animated: false)
            eventMap.scrollEnabled = false
            eventMap.zoomEnabled = false

            if let name = eventLocationName {
                let locationAnnotation = MKPointAnnotation()
                locationAnnotation.coordinate = location
                locationAnnotation.title = name
                eventMap.addAnnotation(locationAnnotation)
                eventMap.selectAnnotation(locationAnnotation, animated: true)
            }

        } else {
            eventMap.hidden = true
        }

    }

    // MARK:- Tap Actions

    @IBAction func mapWasTapped() {
        let alertController = UIAlertController(title: "Need directions?", message:
            "We'll send you to Maps", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Yes", style: .Default) { (action) in
            self.openDirections()
            })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
    }

    @IBAction func orgImageWasTapped() {
        guard let url = organizationURL else {
            return
        }
        let controller = SFSafariViewController(URL: url)
        controller.view.tintColor = Config.tintColor
        presentViewController(controller, animated: true, completion: nil)
    }

    func openDirections() {

        let placemark = MKPlacemark(coordinate: eventLocation!, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        if eventLocationName != nil {
            mapItem.name = eventLocationName
        }

        let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
        // Get the "Current User Location" MKMapItem
        let currentLocationMapItem = MKMapItem.mapItemForCurrentLocation()

        PFAnalytics.trackEventInBackground("openedDirections", dimensions:nil, block: nil)
        // Pass the current location and destination map items to the Maps app
        // Set the direction mode in the launchOptions dictionary
        MKMapItem.openMapsWithItems([currentLocationMapItem, mapItem],
            launchOptions:launchOptions)
    }

}
