import Foundation
import UIKit

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
