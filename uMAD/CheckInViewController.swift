import Foundation
import UIKit
import AVFoundation

class CheckInViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var previewLayer: AVCaptureVideoPreviewLayer?
    var targetLayer: CALayer?
    lazy var captureSession: AVCaptureSession? = self.initializeSession()


    var codeObjects = [AVMetadataObject]()

    func initializeSession() -> AVCaptureSession? {
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        if device.autoFocusRangeRestrictionSupported {
            do {
                try device.lockForConfiguration()
                device.autoFocusRangeRestriction = .Near
                device.unlockForConfiguration()
            } catch {
                // This configuration isn't a must so, just continue
            }
        }
        let deviceInput: AVCaptureDeviceInput
        do {
            deviceInput = try AVCaptureDeviceInput(device: device)
        } catch {
            return nil
        }
        let session = AVCaptureSession()
        if session.canAddInput(deviceInput) {
            session.addInput(deviceInput)
        }
        let metadataOutput = AVCaptureMetadataOutput()
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
            metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: session)!
        previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewLayer!.frame = view.bounds
        view.layer.addSublayer(previewLayer!)

        targetLayer = CALayer()
        targetLayer!.frame = view.bounds
        view.layer.addSublayer(targetLayer!)
        return session
    }

    // MARK: - UIViewController

    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
        codeObjects.removeAll()
        captureSession?.startRunning()

    }
    override func viewDidLoad() {
        captureSession?.stopRunning()
    }

    // MARK: - Check-in Flow

    func checkIn(userId: String) {
        let query = User.query()
        query?.whereKey("objectId", equalTo: userId)
        query?.findObjectsInBackgroundWithBlock({ (results, error) -> Void in
            guard let user = results?.first as? User else {
                return
            }
            UMADApplicationStatus.fetchApplicationStatusWithUser(user, success: { (status) -> () in
                print("Did check in")
                if status.arrivedAt == nil {
                    status.arrivedAt = NSDate()
                    status.saveInBackgroundWithBlock({ (success, error) -> Void in
                        print("Check in saved")
                    })
                } else {
                    //Already checked in
                }
                }, error: { (error) -> () in
                    print(error)
            })
        })
    }

    // MARK: - Metadata Display

    func clearTargetLayer() {
        guard let sublayers = targetLayer?.sublayers else {
            return
        }
        for subLayer in sublayers {
            subLayer.removeFromSuperlayer()
        }
    }

    func showDetectedObjects() {
        for object in codeObjects {
            if let object = object as? AVMetadataMachineReadableCodeObject {
                let shapeLayer = CAShapeLayer()
                shapeLayer.strokeColor = UIColor.redColor().CGColor
                shapeLayer.fillColor = UIColor.clearColor().CGColor
                shapeLayer.lineWidth = 2.0
                shapeLayer.lineJoin = kCALineJoinRound
                if let corners = object.corners as? [CFDictionary] {
                    let path = createPathForPoints(corners)
                    shapeLayer.path = path
                    targetLayer?.addSublayer(shapeLayer)
                }
            }
            // just show one for now
            return
        }
    }

    func createPathForPoints(points: [CFDictionary]!) -> (CGMutablePath) {
        let path = CGPathCreateMutable()
        var point = CGPoint()
        if points.count > 0 {
            CGPointMakeWithDictionaryRepresentation(points[0], &point)
            CGPathMoveToPoint(path, nil, point.x, point.y)
            var i = 1
            while i < points.count {
                CGPointMakeWithDictionaryRepresentation(points[i], &point)
                CGPathAddLineToPoint(path, nil, point.x, point.y)
                i++
            }
            CGPathCloseSubpath(path)
        }
        return path
    }
    // MARK: - AVCaptureMetadataOutputObjectsDelegate

    func captureOutput(captureOutput: AVCaptureOutput!,
        didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
            guard let metadataObjects = metadataObjects as? [AVMetadataObject] else {
                return
            }
        codeObjects.removeAll()
        for object in metadataObjects {
            let transformed = previewLayer?.transformedMetadataObjectForMetadataObject(object)!
            codeObjects.append(transformed!)
            // Just one for now
            break
        }
        clearTargetLayer()
        showDetectedObjects()
        if let toCheckIn = codeObjects.first as? AVMetadataMachineReadableCodeObject {
            let userId = toCheckIn.stringValue
            checkIn(userId)
        }
        captureSession?.stopRunning()
    }
}
