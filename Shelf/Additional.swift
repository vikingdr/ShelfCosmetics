//
//  Additional.swift
//  Gettr
//
//  Created by Nathan Konrad on 09.07.15.
//  Copyright (c) 2015 Nathan Konrad. All rights reserved.
//

import UIKit

enum BrandName : String {
    case Opi = "OPI",
    Essie = "Essie",
    Zoya = "ZOYA",
    Shellac = "Shellac",
    Gelish = "Gelish",
    Butter_London = "Butter London",
    China_Glaze = "China Glaze",
    Color_Club = "Color Club",
    Deborah_Lippmann = "Deborah Lippmann",
    Ibd = "ibd",
    Julep = "Julep",
    Ciate = "Ciate",
    Nails_Inc = "Nails Inc. ",
    Orly = "ORLY",
    Red_Carpet_Manicure = "Red Carpet Manicure",
    Sally_Hansen = "Sally Hansen",
    Sinful_Colors = "Sinful Colors"
    
    static let allValues = [Butter_London, China_Glaze, Ciate, Color_Club, Deborah_Lippmann, Essie, Gelish, Ibd, Julep, Nails_Inc, Opi, Orly, Red_Carpet_Manicure, Sally_Hansen, Shellac, Sinful_Colors, Zoya]
}

func setImageViewFromBrand(_ brandName : String?, imgViewBrand : UIImageView) -> UIImageView{
    if let brand = brandName {
    switch (brand) {
        case BrandName.Gelish.rawValue:
            imgViewBrand.image = UIImage(named: "gelishLogo")
            break
        case BrandName.Zoya.rawValue:
            imgViewBrand.image = UIImage(named: "zoyaLogo")
            break
        case BrandName.Opi.rawValue:
            imgViewBrand.image = UIImage(named: "opiLogo")
            break
        case BrandName.Essie.rawValue:
            imgViewBrand.image = UIImage(named: "essieLogo")
            break
        case BrandName.Shellac.rawValue:
            imgViewBrand.image = UIImage(named: "shellacLogo")
            break
        case BrandName.Butter_London.rawValue:
            imgViewBrand.image = UIImage(named: "butterLondonLogo")
            break
        case BrandName.China_Glaze.rawValue:
            imgViewBrand.image = UIImage(named: "chinaGlazeLogo")
            break
        case BrandName.Color_Club.rawValue:
            imgViewBrand.image = UIImage(named: "colorClubLogo")
            break
        case BrandName.Deborah_Lippmann.rawValue:
            imgViewBrand.image = UIImage(named: "deborahLippmannLogo")
            break
        case BrandName.Ibd.rawValue:
            imgViewBrand.image = UIImage(named: "ibdLogo")
            break
        case BrandName.Julep.rawValue:
            imgViewBrand.image = UIImage(named: "julepLogo")
            break
        case BrandName.Ciate.rawValue:
            imgViewBrand.image = UIImage(named: "ciateLogo")
            break
        case BrandName.Nails_Inc.rawValue:
            imgViewBrand.image = UIImage(named: "nailsIncLogo")
            break
        case BrandName.Orly.rawValue:
            imgViewBrand.image = UIImage(named: "orlyLogo")
            break
        case BrandName.Red_Carpet_Manicure.rawValue:
            imgViewBrand.image = UIImage(named: "redCarpetManicureLogo")
            break
        case BrandName.Sally_Hansen.rawValue:
            imgViewBrand.image = UIImage(named: "sallyHansenLogo")
            break
        case BrandName.Sinful_Colors.rawValue:
            imgViewBrand.image = UIImage(named: "sinfulColorsLogo")
            break
        default:
            imgViewBrand.isHidden = true
        }
    }
    return imgViewBrand
}

extension Date {
    func  getTimeAgoAsString(_ isFullWriten:Bool) -> String {
        
        var minString = "minutes"
        var hourString = "hour"
        if !isFullWriten {
            minString = "min"
            hourString = "hr"
        }
        let dateDiff = Int(floor(Date().timeIntervalSince(self)))
        if dateDiff < 0 {
            let dateFormat : DateFormatter = DateFormatter()
            dateFormat.locale = Locale(identifier: "en_US_POSIX")
            dateFormat.dateFormat = "HH:mm dd MMM"
            return dateFormat.string(from: self)
        }
        
        let nrSeconds : Int = dateDiff//components.second;
        let nrMinutes : Int = nrSeconds / 60
        let nrHours : Int = nrSeconds / 3600
        let nrDays : Int = dateDiff / 86400 //components.day;
        
        var time : String = ""
        
        if (nrDays > 5){
            let dateFormat : DateFormatter = DateFormatter()
            dateFormat.locale = Locale(identifier: "en_US_POSIX")
            dateFormat.dateStyle = DateFormatter.Style.short
            dateFormat.timeStyle = DateFormatter.Style.none
            
            time = "\(dateFormat.string(from: self))"
        } else {
            // days=1-5
            if nrDays > 0 {
                if nrDays == 1 {
                    time = "1 day";
                } else {
                    time = "\(nrDays) days"
                }
            } else {
                if nrHours == 0 {
                    if nrMinutes < 2 {
                        time = "just now"
                    } else {
                        time = "\(nrMinutes) \(minString)"
                    }
                } else { // days=0 hours!=0
                    if nrHours == 1 {
                        time = "1 \(hourString)"
                    } else {
                        time = "\(nrHours) \(hourString)s"
                    }
                }
            }
        }
        
        return time
    }
    
    func getTimeAsString(_ isFullWriten:Bool) -> String {
        var dayString = "day"
        var minString = "minute"
        var hourString = "hour"
        if !isFullWriten {
            dayString = "d"
            minString = "m"
            hourString = "h"
        }
        let dateDiff = Int(floor(Date().timeIntervalSince(self)))
        if dateDiff < 0 {
            let dateFormat : DateFormatter = DateFormatter()
            dateFormat.dateFormat = "MM/dd/yy"
            return dateFormat.string(from: self)
        }
        
        let nrSeconds : Int = dateDiff//components.second;
        let nrMinutes : Int = nrSeconds / 60
        let nrHours : Int = nrSeconds / 3600
        let nrDays : Int = dateDiff / 86400 //components.day;
        
        var time : String = ""
        
        if (nrDays > 5){
            let dateFormat : DateFormatter = DateFormatter()
            
            dateFormat.dateStyle = DateFormatter.Style.short
            dateFormat.timeStyle = DateFormatter.Style.none
            
            time = "\(dateFormat.string(from: self))"
        } else {
            // days=1-5
            if nrDays > 0 {
                if nrDays == 1 {
                    time = "1\(dayString)";
                } else {
                    time = "\(nrDays)\(dayString)"
                    if isFullWriten {
                        time += "s"
                    }
                }
            } else {
                if nrHours == 0 {
                    if nrMinutes < 2 {
                        time = "just now"
                    } else {
                        time = "\(nrMinutes)\(minString)"
                        if isFullWriten {
                            time += "s"
                        }
                    }
                } else { // days=0 hours!=0
                    if nrHours == 1 {
                        time = "1\(hourString)"
                    } else {
                        time = "\(nrHours)\(hourString)"
                        if isFullWriten {
                            time += "s"
                        }
                    }
                }
            }
        }
        
        return time
    }
}

extension Array {
    
    mutating func removeObject<U: Equatable>(_ object: U) {
        var index: Int?
        for (idx, objectToCompare) in self.enumerated() {
            if let to = objectToCompare as? U {
                if object == to {
                    index = idx
                }
            }
        }
        
        if(index != nil) {
            self.remove(at: index!)
        }
    }
}

extension UIImage {
    func resizeImageToSize( _ size: CGSize) -> UIImage? {
        var dstSize = size
        dstSize = CGSize(width: dstSize.width * 1.75, height: dstSize.height * 1.75)
        
        let imgRef = self.cgImage
        
        let srcSize = CGSize(width: CGFloat((imgRef?.width)!), height: CGFloat((imgRef?.height)!))
        if srcSize.equalTo(dstSize) {
            return self
        }
        
        var scaleRatio: CGFloat = dstSize.width / srcSize.width
        if srcSize.height < srcSize.width {
            scaleRatio = dstSize.height / srcSize.height
        }
        
        let orient = self.imageOrientation
        var transform = CGAffineTransform.identity
        
        switch (orient) {
            case UIImageOrientation.up: //EXIF = 1
                transform = CGAffineTransform.identity
                break
                
            case UIImageOrientation.upMirrored: //EXIF = 2
                transform = CGAffineTransform(translationX: srcSize.width, y: 0.0)
                transform = transform.scaledBy(x: -1.0, y: 1.0)
                break
                
            case UIImageOrientation.down: //EXIF = 3
                transform = CGAffineTransform(translationX: srcSize.width, y: srcSize.height)
                transform = transform.rotated(by: CGFloat(M_PI))
                break
                
            case UIImageOrientation.downMirrored: //EXIF = 4
                transform = CGAffineTransform(translationX: 0.0, y: srcSize.height)
                transform = transform.scaledBy(x: 1.0, y: -1.0)
                break
                
            case UIImageOrientation.leftMirrored: //EXIF = 5
                dstSize = CGSize(width: dstSize.height, height: dstSize.width)
                transform = CGAffineTransform(translationX: srcSize.height, y: srcSize.width)
                transform = transform.scaledBy(x: -1.0, y: 1.0);
                transform = transform.rotated(by: 3.0 * CGFloat(M_PI_2))
                break
                
            case UIImageOrientation.left: //EXIF = 6
                dstSize = CGSize(width: dstSize.height, height: dstSize.width);
                transform = CGAffineTransform(translationX: 0.0, y: srcSize.width)
                transform = transform.rotated(by: 3.0 * CGFloat(M_PI_2))
                break
                
            case UIImageOrientation.rightMirrored: //EXIF = 7
                dstSize = CGSize(width: dstSize.height, height: dstSize.width)
                transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
                transform = transform.rotated(by: CGFloat(M_PI_2))
                break
                
            case UIImageOrientation.right: //EXIF = 8
                dstSize = CGSize(width: dstSize.height, height: dstSize.width)
                transform = CGAffineTransform(translationX: srcSize.height, y: 0.0)
                transform = transform.rotated(by: CGFloat(M_PI_2))
                break
            
        }
        
        UIGraphicsBeginImageContextWithOptions(dstSize, false, self.scale)
        let context: CGContext? = UIGraphicsGetCurrentContext()
        
        if context == nil {
            return nil
        }
        
        if orient == UIImageOrientation.right || orient == UIImageOrientation.left {
            context?.scaleBy(x: -scaleRatio, y: scaleRatio)
            context?.translateBy(x: -srcSize.height, y: 0)
        } else {
            context?.scaleBy(x: scaleRatio, y: -scaleRatio)
            context?.translateBy(x: 0, y: -srcSize.height)
        }
        
        context?.concatenate(transform);
        
        // we use srcSize (and not dstSize) as the size to specify is in user space (and we use the CTM to apply a scaleRatio)
        UIGraphicsGetCurrentContext()?.draw(imgRef!, in: CGRect(x: 0, y: 0, width: srcSize.width, height: srcSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
}

class ImageUtil: NSObject {
    static func crop(image originalImage: UIImage, rect : CGRect) -> UIImage {
        // Create a copy of the image without the imageOrientation property so it is in its native orientation (landscape)
        let contextImage: UIImage = UIImage(cgImage: originalImage.cgImage!)

        let posX: CGFloat = (contextImage.size.width - rect.size.width) / 2
        let posY: CGFloat = (contextImage.size.height - rect.size.height) / 2
        
        let rrect = CGRect(x: posX, y: posY, width: rect.size.width, height: rect.size.height)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = contextImage.cgImage!.cropping(to: rrect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef, scale: originalImage.scale, orientation: originalImage.imageOrientation)
        
        return image
    }
}

class Constants: NSObject {
    class func getWidthForText(_ text: String, font: UIFont) -> CGFloat {
        return ceil((text as NSString).boundingRect(with: CGSize(width: CGFloat(NSIntegerMax), height: CGFloat(NSIntegerMax)), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil).size.width)
    }
    
    class func isStringUserTag(_ string: String) -> Bool {
        let letterSet = CharacterSet.alphanumerics
        if string[string.startIndex] == "@" {
            let userNameString = string.substring(from: string.characters.index(string.startIndex, offsetBy: 1))
            if userNameString.trimmingCharacters(in: letterSet) == "" {
                return true
            }
        }
        
        return false
    }
}

extension NSLayoutConstraint {
    
    override open var description: String {
        let id = identifier ?? ""
        return "id: \(id), constant: \(constant)"
    }
}
