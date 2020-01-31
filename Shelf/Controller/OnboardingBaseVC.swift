//
//  OnboardingBaseVC.swift
//  Shelf
//
//  Created by Nathan Konrad on 11/22/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation
import UIKit
import RazzleDazzle

class OnboardingBaseVC : AnimatedPagingScrollViewController {

    //Page 1
    let backgroundImage1 = UIImageView(image : UIImage(named: "BackgroundScreen1"))
    let commentExample = UIImageView(image : UIImage(named: "CommentExample"))
    let commentIcon = UIImageView(image : UIImage(named: "CommentIcon"))
    let profileExample = UIImageView(image : UIImage(named: "ProfileExample"))
    let shelfieExample = UIImageView(image : UIImage(named: "ShelfieExample"))
    let swatchesIcon = UIImageView(image : UIImage(named: "SwatchesIcon"))
    let trendingIcon = UIImageView(image : UIImage(named: "TrendingIcon"))
    
    //Page2
    let cameraIcon = UIImageView(image : UIImage(named: "CameraIcon"))
    let coconutExample = UIImageView(image : UIImage(named: "CoconutExample"))
    let heartIcon = UIImageView(image : UIImage(named: "HeartIcon"))
    let nailPolishAddIcon = UIImageView(image : UIImage(named: "NailPolishAddIcon"))
    let pinIcon = UIImageView(image : UIImage(named: "PinIcon"))
    let selectABrandExample = UIImageView(image : UIImage(named: "SelectABrandExample"))
    let shelfieFlippedExample = UIImageView(image : UIImage(named: "ShelfieFlippedExample"))
    
    //Page3
    let butterLondonIcon = UIImageView(image : UIImage(named: "ButterLondonIcon"))
    let butterLondonImageExample = UIImageView(image : UIImage(named: "ButterLondonImageExample"))
    let clipboardIcon = UIImageView(image : UIImage(named: "ClipboardIcon"))
    let julepIcon = UIImageView(image : UIImage(named: "JulepIcon"))
    let julepImageExample = UIImageView(image : UIImage(named: "JulepImageExample"))
    let noChemicalsIcon = UIImageView(image : UIImage(named: "NoChemicalsIcon"))
    let searchIcon = UIImageView(image : UIImage(named: "SearchIcon"))
    let shellacCircleIcon = UIImageView(image : UIImage(named: "ShellacCircleIcon"))
    let shellacImageExample = UIImageView(image : UIImage(named: "ShellacImageExample"))
    
    //Page4
    let amexIcon = UIImageView(image : UIImage(named: "AmexIcon"))
    let applePayIcon = UIImageView(image : UIImage(named: "ApplePayIcon"))
    let applePayIconBlack = UIImageView(image : UIImage(named: "ApplePayIconBlack"))
    let buyNowButtonIcon = UIImageView(image : UIImage(named: "BuyNowButtonIcon"))
    let centerProductIcon = UIImageView(image : UIImage(named: "CenterProductIcon"))
    let discoverIcon = UIImageView(image : UIImage(named: "DiscoverIcon"))
    let fireworksIcon = UIImageView(image : UIImage(named: "FireworksIcon"))
    let leftProductIcon = UIImageView(image : UIImage(named: "LeftProductIcon"))
    let masterCardIcon = UIImageView(image : UIImage(named: "MasterCardIcon"))
    let promoCode = UIImageView(image : UIImage(named: "PromoCode"))
    let rightProduct = UIImageView(image : UIImage(named: "RightProduct"))
    let visaIcon = UIImageView(image : UIImage(named: "VisaIcon"))
    
    
    func calculateCenterXOffset(_ xOffset: CGFloat, width : CGFloat) -> CGFloat {
        let ratioWidth = (view.frame).width / CGFloat((kiPhone6ScreenWidth))
        
        var centerXOffset = (pageWidth / 2)
        centerXOffset = ((xOffset * ratioWidth) + ((width * ratioWidth) / 2)) - centerXOffset
        return centerXOffset / pageWidth
    }
    
    func calculateCenterYOffset(_ yOffset: CGFloat, height: CGFloat) -> CGFloat {
        var centerYOffset = (view.frame).height / 2
        centerYOffset = (yOffset + (height / 2)) - centerYOffset
        return centerYOffset
    }

}
