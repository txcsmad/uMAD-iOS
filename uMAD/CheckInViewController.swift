import Foundation
import UIKit
import Parse

class CheckInViewController: UIViewController {
    @IBOutlet weak var qrCode: UIImageView!
    @IBOutlet weak var checkInStatus: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    var status: UMADApplicationStatus!
    private var recheckTimer: NSTimer?

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let id = User.currentUser()?.objectId else {
            dismissViewControllerAnimated(true, completion: nil)
            return
        }
        idLabel.text = id
        let rawImage = createQRForString(id)
        let scaleX = qrCode.frame.width / rawImage.extent.width
        let scaleY = qrCode.frame.height / rawImage.extent.height

        let transformedImage = rawImage.imageByApplyingTransform(CGAffineTransformMakeScale(scaleX, scaleY))

        let image = UIImage(CIImage: transformedImage)
        qrCode.image = image
        updateCheckInStatus()
        recheckTimer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "updateCheckInStatus", userInfo: nil, repeats: true)

    }

    func updateCheckInStatus() {
        guard let currentUser = User.currentUser() else {
            return
        }
        status.fetchInBackgroundWithBlock { (result, error) -> Void in
            guard let status = result as? UMADApplicationStatus else {
                return
            }
            if status.arrivedAt == nil {
                self.view.backgroundColor = UIColor.redColor()
                self.checkInStatus.text = "You have not checked in"
            } else {
                self.view.backgroundColor = UIColor.greenColor()
                self.checkInStatus.text = "You are checked in"
                self.recheckTimer?.invalidate()
                self.recheckTimer = nil
            }
        }
    }

    func createQRForString(string: String) -> CIImage {
        let nsString = string as NSString
        let stringData = nsString.dataUsingEncoding(NSISOLatin1StringEncoding, allowLossyConversion: false)
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")!
        qrFilter.setValue(stringData, forKey: "inputMessage")
        qrFilter.setValue("Q", forKey: "inputCorrectionLevel")
        return qrFilter.outputImage!
    }

    func createNonInterpolatedUIImageFromCIImage(image: CIImage, scale: CGFloat) -> UIImage {
        // Render the CIImage into a CGImage
        let cgImage = CIContext(options: nil).createCGImage(image, fromRect: image.extent)

        // Now we'll rescale using CoreGraphics
        UIGraphicsBeginImageContext(CGSize(width: image.extent.size.width * scale, height: image.extent.size.width * scale))
        let context = UIGraphicsGetCurrentContext()
        // We don't want to interpolate (since we've got a pixel-correct image)
        CGContextSetInterpolationQuality(context, .None)
        CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage)
        // Get the image out
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        // Tidy up
        UIGraphicsEndImageContext()
        return scaledImage
    }
}
