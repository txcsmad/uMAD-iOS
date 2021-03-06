import Foundation
import UIKit
import AVFoundation

public class QRScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var targetLayer: CALayer?
    private lazy var captureSession: AVCaptureSession? = self.initializeSession()
    private var codeObjects = [AVMetadataObject]()
    internal var acceptingNewScans = false
    // Options
    public var stopOnFirstCapture = true
    private var maxQRCodes: UInt = 1
    public var maxSimultaneousQRCodes: UInt {
        get {
            return maxQRCodes
        }
        set(newValue) {
            if newValue < 1 || 4 < newValue {
                maxQRCodes = newValue
            }
        }
    }



    private func initializeSession() -> AVCaptureSession? {
        // Does this device have a camera?
        guard UIImagePickerController.isSourceTypeAvailable(.Camera) else {
            return nil
        }
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

    public override func viewDidLoad() {
        view.backgroundColor = UIColor.blackColor()
    }

    override public func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
        codeObjects.removeAll()
        startCapturing()
    }

    // MARK: - Metadata Display

    private func clearTargetLayer() {
        guard let sublayers = targetLayer?.sublayers else {
            return
        }
        for subLayer in sublayers {
            subLayer.removeFromSuperlayer()
        }
    }

    private func showDetectedObjects() {
        var count: UInt = 0
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
                count++
                if count > maxQRCodes {
                    break
                }
            }
        }
    }

    private func createPathForPoints(points: [CFDictionary]!) -> (CGMutablePath) {
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

    public func captureOutput(captureOutput: AVCaptureOutput!,
        didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
            guard let metadataObjects = metadataObjects as? [AVMetadataObject] else {
                return
            }
        codeObjects.removeAll()
        let acceptedObjects = metadataObjects.prefix(Int(maxQRCodes))
        for object in acceptedObjects {
            let transformed = previewLayer?.transformedMetadataObjectForMetadataObject(object)!
            codeObjects.append(transformed!)
        }
        clearTargetLayer()
        showDetectedObjects()

        for object in acceptedObjects {
            if let toHandle = object as? AVMetadataMachineReadableCodeObject {
                let userId = toHandle.stringValue
                if acceptingNewScans {
                    didCaptureCode(userId)
                }
            }
        }
        // This metod will stop accepting scans and spin the session down,
        // guaranteeing that this delegate method isn't called until we spin back up.
        if acceptingNewScans && stopOnFirstCapture {
            stopCapturing()
        }
    }

    // MARK: - QR Code Handling

    public func didCaptureCode(string: String) {
        // NOP
    }

    func acceptScansAfter(delay: NSTimeInterval) {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) { () -> Void in
            self.acceptingNewScans = true
        }
    }

    // MARK: - Session Management

    public func stopCapturing() {
        acceptingNewScans = false
        captureSession?.stopRunning()
    }

    public func startCapturing() {
        acceptScansAfter(3.0)
        clearTargetLayer()
        captureSession?.startRunning()
    }


}
