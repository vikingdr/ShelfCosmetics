//
//  StringExtension.swift
//  Shelf
//
//  Created by Nathan Konrad on 8/30/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import UIKit
import MapKit
import PhoneNumberKit
extension String {
    var first: String {
        return String(characters.prefix(1))
    }
    
    var capitalizedSentence: String {
        return first.uppercased() + String(characters.dropFirst())
    }
    
    func verifyPhoneNumber() -> Bool {
        var isValidPhone = true
//        do {
//			let phoneNumberParsed = try PhoneNumber(rawNumber: self)
//            let phoneNumberParsed = try PhoneNumber(rawNumber: self )
            if self.characters.count < 8 /*|| phoneNumberParsed.isValidNumber == false*/ {
                isValidPhone = false
            }
//        }catch {
//            print("Generic parser error")
//            isValidPhone = false
//        }
        return isValidPhone
    }
    
    func verifyFullName() -> Bool {
        let fullName = self.characters.split{$0 == " "}.map(String.init)
        return fullName.count >= 2
    }
    
    func formatStringToDate() -> Date? {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
        return f.date(from: self)
    }
    
    func verifyEmail() -> Bool {
        var currentStringTrimmed = self
        currentStringTrimmed.trim()
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: currentStringTrimmed)
    }
    
    public mutating func trim() {
        self = self.trimmed()
    }
    
    public func trimmed() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

}

extension UITextView {
    func addDoneToolBar() {
        self.autocorrectionType = UITextAutocorrectionType.no

            let toolBar = UIToolbar()
            let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(UITextView.donePressed))
            let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
            toolBar.setItems([spaceButton, doneButton], animated: false)
            toolBar.isUserInteractionEnabled = true
            toolBar.sizeToFit()
            self.inputAccessoryView = toolBar
    }

    func donePressed() {
        self.resignFirstResponder()
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func roundToPlaces(_ places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
		let num = self
		return Darwin.round(num * Double(divisor)) / Double(divisor)
    }
}

extension UIViewController{
    func createMapSnapshot(_ color : SColor?, width : CGFloat, completion : ((SColor?) -> ())?){
        if let geoPt = color?.geopoint {
            let coord = CLLocationCoordinate2D(latitude: geoPt.latitude, longitude: geoPt.longitude)
            let region = MKCoordinateRegion(center: coord, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
            let options = MKMapSnapshotOptions()
            options.region = region
            let productImgViewWidth = width
            options.size = CGSize(width: productImgViewWidth, height: 107)
            options.scale = UIScreen.main.scale
            let snapshotter = MKMapSnapshotter(options: options)
            snapshotter.start(completionHandler: { (snapshot, error) in
                guard let snapshot = snapshot else {
                    print("error occurred creating snapshot \(error)")
                    if let comp = completion {
                        comp(nil)
                    }
                    return
                }
                let image = snapshot.image
                let ptAn = MKPointAnnotation()
                ptAn.coordinate = coord
                let annotation = MKAnnotationView(annotation: ptAn, reuseIdentifier: nil)
                annotation.image = UIImage(named: "RedPinIcon")
                let pinImage = annotation.image
                UIGraphicsBeginImageContextWithOptions(image.size, true, image.scale)
                image.draw(at: CGPoint(x: 0, y: 0))
                var point = snapshot.point(for: coord)
                point.y = point.y - annotation.image!.size.height
                pinImage?.draw(at: point)
                let finalImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                color?.mapsnapShot = finalImage
                if let comp = completion {
                    comp(color)
                }
            })
        }
    }
    func setupNavBarModal(_ name : String ) {
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(named: "Navigationbar")!.resizableImage(withCapInsets: UIEdgeInsetsMake(0, 0, 0, 0), resizingMode: .stretch), for: UIBarMetrics.default)
        
        let label = UILabel()
        let attributes: NSDictionary = [
            NSFontAttributeName:UIFont(name: "Avenir-Black", size: 16)!,
            NSForegroundColorAttributeName:UIColor.white,
            NSKernAttributeName:CGFloat(0.4)
        ]
        
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        
        self.navigationController?.navigationBar.layer.shadowRadius = 2.0
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.15
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        let attributedTitle = NSAttributedString(string: name, attributes: attributes as? [String : AnyObject])
        
        label.attributedText = attributedTitle
        label.sizeToFit()
        self.navigationItem.titleView = label
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "closeButton"), style: .plain, target: self, action: #selector(UIViewController.backPressedModal))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
    }
    
    func backPressedModal(){
        
    }
}

extension UIView {
    func roundAndAddDropShadow(_ cornerRadius: CGFloat, shadowOpacity: Float, width: Int = 0, height: Int = 2, shadowRadius: CGFloat = 1) {
        // Map to corner radius
        self.layer.cornerRadius = cornerRadius
        // Map to color
        self.layer.shadowColor = UIColor.black.cgColor
        // Map to x and y respectively
        self.layer.shadowOffset = CGSize(width: width, height: height)
        // Map to alpha
        self.layer.shadowOpacity = shadowOpacity
        // Map to blur
        self.layer.shadowRadius = shadowRadius
    }
    
    func removeDropShadow(){
        self.layer.cornerRadius = 0
        // Map to color
        self.layer.shadowColor = UIColor.clear.cgColor
        // Map to x and y respectively
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        // Map to alpha
        self.layer.shadowOpacity = 0
        // Map to blur
        self.layer.shadowRadius = 0
    }


        func round(_ corners: UIRectCorner, radius: CGFloat) {
            _round(corners, radius: radius)
        }
    
        func round(_ corners: UIRectCorner, radius: CGFloat, borderColor: UIColor, borderWidth: CGFloat) {
            let mask = _round(corners, radius: radius)
            addBorder(mask, borderColor: borderColor, borderWidth: borderWidth)
        }
        
        func fullyRound(_ diameter: CGFloat, borderColor: UIColor, borderWidth: CGFloat) {
            layer.masksToBounds = true
            layer.cornerRadius = diameter / 2
            layer.borderWidth = borderWidth
            layer.borderColor = borderColor.cgColor;
        }
    
    func _round(_ corners: UIRectCorner, radius: CGFloat) -> CAShapeLayer {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
        return mask
    }
    
    func addBorder(_ mask: CAShapeLayer, borderColor: UIColor, borderWidth: CGFloat) {
        let borderLayer = CAShapeLayer()
        borderLayer.path = mask.path
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = borderColor.cgColor
        borderLayer.lineWidth = borderWidth
        borderLayer.frame = bounds
        layer.addSublayer(borderLayer)
    }
}

extension UILabel{
    
    func requiredHeight() -> CGFloat{
        
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = self.font
        label.text = self.text
        
        label.sizeToFit()
        
        return label.frame.height
    }
}

extension Date {
    func formatDateToShortStyleString() -> String {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .none
        return f.string(from: self)
    }
}

extension NSDecimalNumber {
    var currencyFormat: String? {        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.currency
        return numberFormatter.string(from: self)
    }
}

extension UIImage {
    public func imageRotatedByDegrees(_ degrees: CGFloat, flip: Bool) -> UIImage {
        let radiansToDegrees: (CGFloat) -> CGFloat = {
            return $0 * (180.0 / CGFloat(M_PI))
        }
        let degreesToRadians: (CGFloat) -> CGFloat = {
            return $0 / 180.0 * CGFloat(M_PI)
        }

        var scaledSize = size
        scaledSize.height = scaledSize.height * scale
        scaledSize.width = scaledSize.width * scale
        // calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox = UIView(frame: CGRect(origin: CGPoint.zero, size: scaledSize))
        let t = CGAffineTransform(rotationAngle: degreesToRadians(degrees));
        rotatedViewBox.transform = t
        let rotatedSize = rotatedViewBox.frame.size

        // Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap = UIGraphicsGetCurrentContext()

        // Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap?.translateBy(x: rotatedSize.width / 2.0, y: rotatedSize.height / 2.0);

        //   // Rotate the image context
        bitmap?.rotate(by: degreesToRadians(degrees));

        // Now, draw the rotated/scaled image into the context
        var yFlip: CGFloat

        if(flip){
            yFlip = CGFloat(-1.0)
        } else {
            yFlip = CGFloat(1.0)
        }

        bitmap?.scaleBy(x: yFlip, y: -1.0)
        bitmap?.draw(cgImage!, in: CGRect(x: -scaledSize.width / 2, y: -scaledSize.height / 2, width: scaledSize.width, height: scaledSize.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}

extension NSObject {
    func compressImage(_ image : UIImage) -> Data {
        let imgData = NSData(data: UIImageJPEGRepresentation(image, 1)!) as Data
        let imgSize = (imgData.count / 1024)  // Size in kb
        var imgCompressed : Data!
        print("Size before \(imgSize)")
        if imgSize < 1000 {
            imgCompressed = UIImageJPEGRepresentation(image, 1)!
        }
        else if imgSize < 2000 { //1000 - 1999
            imgCompressed = UIImageJPEGRepresentation(image, 0.5)!
        }
        else if imgSize < 3000 { //2000 - 2999
            imgCompressed =  UIImageJPEGRepresentation(image, 0.33)!
        }
        else {
            imgCompressed = UIImageJPEGRepresentation(image, 0.25)
        }
        return imgCompressed
    }
}
