//
//  OnboardingVC.swift
//  Shelf
//
//  Created by Nathan Konrad on 11/22/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import ParseFacebookUtilsV4
import Firebase
import MBProgressHUD
import RazzleDazzle
import SpriteKit

let kiPhone6ScreenWidth: CGFloat = 375
let kiPhone6ScreenHeight: CGFloat = 667

let kOnboardingVCIdentifier = "OnboardingVC"
let kKeyOnboardingSeen = "OnboardingSeen"

class OnboardingVC: OnboardingBaseVC {
    
    // Splash
    @IBOutlet weak var splashView: UIView!
    @IBOutlet weak var splashBackgroundSKView: SKView!
    @IBOutlet weak var splashBackgroundOverlayImageView: UIImageView!
    
    // Onboarding Shelf Cosmetics Logo Overlay
    @IBOutlet weak var onboardingView: UIView!
    @IBOutlet weak var shelfCosmeticsLogoImageView: UIImageView!
    
    // Onboarding
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var bottomBarView: UIView!
    @IBOutlet weak var loginButtonView: UIView!
    @IBOutlet weak var loginButton: ShelfButton!
    @IBOutlet weak var joinButtonView: UIView!
    @IBOutlet weak var joinButton: ShelfButton!
    @IBOutlet weak var joinBottomBarView: UIView!
    @IBOutlet weak var joinWithEmailButtonView: UIView!
    @IBOutlet weak var joinWithEmailButton: ShelfButton!
    @IBOutlet weak var joinWithFacebookButtonView: UIView!
    @IBOutlet weak var joinWithFacebookButton: ShelfButton!
    
    @IBOutlet weak var onboardingViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var onboardingViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var onboardingViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var onboardingViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var shelfCosmeticsLogoImageViewCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var shelfCosmeticsLogoImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var shelfCosmeticsLogoImageViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet weak var pageControlBottomConstraint: NSLayoutConstraint!
    
    fileprivate var onboardingContraints = [[NSLayoutConstraint]]()
    fileprivate let kNumberOfPages = 4
    fileprivate var logging: Bool = false
      let screenWidth = UIScreen.main.bounds.size.width
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSplashBackgroundAnimations()
        /*
        shelfieFlippedExample.image = UIImage(named: "ShelfieFlippedExample")!.imageRotatedByDegrees(-90, flip: false)
        cameraIcon.image = UIImage(named: "CameraIcon")!.imageRotatedByDegrees(-90, flip: false)
        coconutExample.image = UIImage(named: "CoconutExample")!.imageRotatedByDegrees(-90, flip: false)
        heartIcon.image = UIImage(named: "HeartIcon")!.imageRotatedByDegrees(-90, flip: false)
        nailPolishAddIcon.image = UIImage(named: "NailPolishAddIcon")!.imageRotatedByDegrees(-90, flip: false)
        pinIcon.image = UIImage(named: "PinIcon")!.imageRotatedByDegrees(-90, flip: false)
        selectABrandExample.image = UIImage(named: "SelectABrandExample")!.imageRotatedByDegrees(-90, flip: false)
        
        butterLondonIcon.image = UIImage(named: "ButterLondonIcon")!.imageRotatedByDegrees(-90, flip: false)
        butterLondonImageExample.image = UIImage(named: "ButterLondonImageExample")!.imageRotatedByDegrees(-90, flip: false)
        clipboardIcon.image = UIImage(named: "ClipboardIcon")!.imageRotatedByDegrees(-90, flip: false)
        julepIcon.image =  UIImage(named: "JulepIcon")!.imageRotatedByDegrees(-90, flip: false)
        julepImageExample.image = UIImage(named: "JulepImageExample")!.imageRotatedByDegrees(-90, flip: false)
        noChemicalsIcon.image = UIImage(named: "NoChemicalsIcon")!.imageRotatedByDegrees(-90, flip: false)
        searchIcon.image =  UIImage(named: "SearchIcon")!.imageRotatedByDegrees(-90, flip: false)
        shellacCircleIcon.image =  UIImage(named: "ShellacCircleIcon")!.imageRotatedByDegrees(-90, flip: false)
        shellacImageExample.image =  UIImage(named: "ShellacImageExample")!.imageRotatedByDegrees(-90, flip: false)
        
        amexIcon.image = UIImage(named: "AmexIcon")!.imageRotatedByDegrees(-90, flip: false)
        applePayIcon.image = UIImage(named: "ApplePayIcon")!.imageRotatedByDegrees(-90, flip: false)
        applePayIconBlack.image = UIImage(named: "ApplePayIconBlack")!.imageRotatedByDegrees(-90, flip: false)
        buyNowButtonIcon.image =  UIImage(named: "BuyNowButtonIcon")!.imageRotatedByDegrees(-90, flip: false)
        centerProductIcon.image =  UIImage(named: "CenterProductIcon")!.imageRotatedByDegrees(-90, flip: false)
        discoverIcon.image =  UIImage(named: "DiscoverIcon")!.imageRotatedByDegrees(-90, flip: false)
        fireworksIcon.image = UIImage(named: "FireworksIcon")!.imageRotatedByDegrees(-90, flip: false)
        leftProductIcon.image =  UIImage(named: "LeftProductIcon")!.imageRotatedByDegrees(-90, flip: false)
        masterCardIcon.image = UIImage(named: "MasterCardIcon")!.imageRotatedByDegrees(-90, flip: false)
        promoCode.image = UIImage(named: "PromoCode")!.imageRotatedByDegrees(-90, flip: false)
        rightProduct.image = UIImage(named: "RightProduct")!.imageRotatedByDegrees(-90, flip: false)
        visaIcon.image =  UIImage(named: "VisaIcon")!.imageRotatedByDegrees(-90, flip: false)
        */
        setupScrollView()
        setupTopBar()
        setupPageControl()
        setupBottomBar()
        showSplashAnimation()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(OnboardingVC.onProfileUpdated(_:)), name: NSNotification.Name.FBSDKProfileDidChange, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    override func numberOfPages() -> Int {
        return kNumberOfPages
    }
    
    // MARK: - Setup helper functions
    func setupSplashBackgroundAnimations() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let scene = GameScene(size: CGSize(width: screenWidth, height: screenHeight))
        var imageName = "SplashBackground"
        getDeviceBackgroundImageName(&imageName)
        scene.makeBackground(imageName, isFirstTime : true)
        splashBackgroundSKView.showsFPS = false
        splashBackgroundSKView.showsNodeCount = false
        splashBackgroundSKView.ignoresSiblingOrder = true
        scene.scaleMode = .resizeFill
        splashBackgroundSKView.presentScene(scene, transition: SKTransition.fade(withDuration: 0.2))
    }
    
    func setupScrollView() {
        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alpha = 0
        setupBackgroundImage()
        setupPage1Constraints()
        setupPage2Constraints()
        setupPage3Constraints()
        setupPage4Constraints()
        
//        edgesForExtendedLayout = UIRectEdge.none
		edgesForExtendedLayout = .all
    }
    
    func setupBackgroundImage(){
        var constraints = [NSLayoutConstraint]()
        var imageName1 = "BackgroundScreen1"
        getDeviceBackgroundImageName(&imageName1)
        setupBackgroundWithImage(imageName1, screen: 0, constraints: &constraints)
        
        var imageName2 = "BackgroundScreen2"
        getDeviceBackgroundImageName(&imageName2)
        setupBackgroundWithImage(imageName2, screen: 1, constraints: &constraints)
        
        var imageName3 = "BackgroundScreen3"
        getDeviceBackgroundImageName(&imageName3)
        setupBackgroundWithImage(imageName3, screen: 2, constraints: &constraints)
        
        var imageName4 = "BackgroundScreen4"
        getDeviceBackgroundImageName(&imageName4)
        setupBackgroundWithImage(imageName4, screen: 3, constraints: &constraints)
    }
    
    func setupTopBar() {
//        view.bringSubviewToFront(shelfLogoImageView)
    }
    
    func setupPageControl() {
        view.bringSubview(toFront: pageControl)
        pageControl.numberOfPages = kNumberOfPages
        pageControl.transform = CGAffineTransform(scaleX: 1.75, y: 1.75)
        
        if constant.DeviceType.IS_IPHONE_4_OR_LESS {
            
        }
        else if constant.DeviceType.IS_IPHONE_5 {
            pageControlBottomConstraint.constant = -5
            view.layoutIfNeeded()
        }
    }
    
    func setupBottomBar() {
        // Bottom Bar View
        view.bringSubview(toFront: bottomBarView)
        loginButtonView.layer.borderWidth = 1
        loginButtonView.layer.borderColor = UIColor.white.cgColor
        loginButtonView.roundAndAddDropShadow(8, shadowOpacity: 0.15, width: 0, height: 1, shadowRadius: 1)
        loginButton.setBackgroundColor(UIColor.init(white: 1, alpha: 0.6), forState: .highlighted)
        loginButton.layer.cornerRadius = 8
        loginButton.layer.masksToBounds = true
        joinButtonView.roundAndAddDropShadow(8, shadowOpacity: 0.15, width: 0, height: 1, shadowRadius: 1)
        joinButton.setBackgroundColor(UIColor.init(white: 1, alpha: 0.6), forState: .highlighted)
        joinButton.layer.cornerRadius = 8
        joinButton.layer.masksToBounds = true
        
        // Join Bottom Bar View
        view.bringSubview(toFront: joinBottomBarView)
        joinWithEmailButtonView.roundAndAddDropShadow(8, shadowOpacity: 0.15, width: 0, height: 1, shadowRadius: 1)
        joinWithEmailButton.setBackgroundColor(UIColor.init(white: 1, alpha: 0.6), forState: .highlighted)
        joinWithEmailButton.layer.cornerRadius = 8
        joinWithEmailButton.layer.masksToBounds = true
        joinWithFacebookButtonView.roundAndAddDropShadow(8, shadowOpacity: 0.15, width: 0, height: 1, shadowRadius: 1)
        joinWithFacebookButton.setBackgroundColor(UIColor.init(white: 1, alpha: 0.6), forState: .highlighted)
        joinWithFacebookButton.layer.cornerRadius = 8
        joinWithFacebookButton.layer.masksToBounds = true
    }
    
    fileprivate func updateFacebookButtonBackground(_ color: UIColor, forState state: UIControlState) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()?.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        joinWithFacebookButton.setBackgroundImage(colorImage, for: state)
    }
    
    fileprivate func showSplashAnimation() {
        let ratioWidth = (view.frame).width / CGFloat(kiPhone6ScreenWidth)
        let ratioHeight = (view.frame).height / CGFloat(kiPhone6ScreenHeight)
        let newCenterY = ratioHeight * -262.5
        let newWidth: CGFloat = 113 * ratioWidth
        let newHeight: CGFloat = 52 * ratioHeight
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // Have animation if showSplash
        if appDelegate.showSplash == true {
            view.bringSubview(toFront: splashView)
            view.bringSubview(toFront: onboardingView)
            
            // Sleep for 2 seconds
            //sleep(2)
            onboardingView.layoutIfNeeded()
            shelfCosmeticsLogoImageViewCenterYConstraint.constant = newCenterY
            shelfCosmeticsLogoImageViewWidthConstraint.constant = newWidth
            shelfCosmeticsLogoImageViewHeightConstraint.constant = newHeight
            
            UIView.animate(withDuration: 2.0, delay: 3.0, options: [], animations: {
                
                self.scrollView.alpha = 1
                self.pageControl.alpha = 1
                self.bottomBarView.alpha = 1
                self.splashView.alpha = 0

                self.onboardingView.layoutIfNeeded()
                }, completion: { (success: Bool) in
                    if success {
                        self.splashView.isHidden = true
                        appDelegate.showSplash = false
                        self.updateSplashLogoView(newCenterY, widthConstant: newWidth, heightConstant: newHeight)
                    }
            })
        }
        // Splash View is hidden
        else {
            view.bringSubview(toFront: onboardingView)
            scrollView.alpha = 1
            pageControl.alpha = 1
            bottomBarView.alpha = 1
            splashView.alpha = 0
            shelfCosmeticsLogoImageViewWidthConstraint.constant = newWidth
            shelfCosmeticsLogoImageViewHeightConstraint.constant = newHeight
            updateSplashLogoView(newCenterY, widthConstant: newWidth, heightConstant: newWidth)
        }
    }
    
    fileprivate func updateSplashLogoView(_ centerYConstant: CGFloat, widthConstant: CGFloat, heightConstant: CGFloat) {
        view.removeConstraints([onboardingViewLeadingConstraint, onboardingViewTrailingConstraint, onboardingViewTopConstraint, onboardingViewBottomConstraint])
        
        let centerX = NSLayoutConstraint(item: onboardingView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        let centerY = NSLayoutConstraint(item: onboardingView, attribute: .centerY, relatedBy:
            .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: centerYConstant)
        let widthConstraint = NSLayoutConstraint(item: onboardingView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: widthConstant)
        let heightConstraint = NSLayoutConstraint(item: onboardingView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: heightConstant)
        NSLayoutConstraint.activate([centerX, centerY, widthConstraint, heightConstraint])

        shelfCosmeticsLogoImageViewCenterYConstraint.constant = centerYConstant
        onboardingView.layoutIfNeeded()
    }
    
    // MARK: - NSNotification
    func onProfileUpdated(_ notification: Notification) {
        print("userInfo: \(notification.userInfo)")
    }
    
    // MARK: - IBAction
    @IBAction func loginButtonPressed(_ sender: AnyObject) {
        transitionToMenuViewController(.login)
    }
    
    @IBAction func joinButtonPressed(_ sender: AnyObject) {
        joinBottomBarView.isHidden = false
        
        UIView.animate(withDuration: 1, animations: { 
            self.bottomBarView.alpha = 0
            self.joinBottomBarView.alpha = 1
        }, completion: { (success: Bool) in
            if success {
                self.bottomBarView.isHidden = true
            }
        }) 
    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        bottomBarView.isHidden = false
        UIView.animate(withDuration: 1, animations: { 
            self.joinBottomBarView.alpha = 0
            self.bottomBarView.alpha = 1
        }, completion: { (success: Bool) in
            if success {
                self.joinBottomBarView.isHidden = true
            }
        }) 
    }
    
    @IBAction func joinWithEmailButtonPressed(_ sender: AnyObject) {
        let vc = storyboard?.instantiateViewController(withIdentifier: kRegistrationVCIdentifier) as! RegistrationViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func joinWithFacebookButtonPressed(_ sender: AnyObject) {
        let loginManager = FBSDKLoginManager()
		loginManager.logIn(withReadPermissions: [], from: self) { (result, error) in
            // Errorred
            if error != nil {
                // Display Alert
                print("error: \(error)")
                self.presentFBLoginErrorAlert()
            }
                // User clicked Cancel on prompt
            else if (result?.isCancelled)! {
                // Display Alert
                self.presentFBLoginErrorAlert()
                print("result.isCancelled: \(result?.isCancelled)")
            }
            //
            else {
                // User granted email permissions
                if (result?.grantedPermissions.contains("email"))! {
                    self.getDetailsAndLogin()
                }
                // User didn't grant email permissions, deny access and log them out
                else {
                    loginManager.logOut()
                    self.logging = false
                }
            }
        }
    }
    
    // MARK: - Helper functions
    func transitionToMenuViewController(_ loginType: LoginType) {
        let vc = storyboard?.instantiateViewController(withIdentifier: kMenuVCIdentifier) as! MenuViewController
        vc.loginType = loginType
        navigationController?.pushViewController(vc, animated: true)
        //NSUserDefaults.standardUserDefaults().setBool(true, forKey: kKeyOnboardingSeen)
        //NSUserDefaults.standardUserDefaults().synchronize()

    }
    
    //sets up frame relative to center of view
    func setupFrame(_ x  : CGFloat , y : CGFloat , width : CGFloat, height : CGFloat) -> CGRect{
        let center = self.view.center
        let xCoord = center.x - ( center.x - x)
        let yCoord = center.y - (center.y - y)
        let ratio = center.x / CGFloat((kiPhone6ScreenWidth / 2))
        let rect = CGRect(x: xCoord * ratio, y: yCoord, width: width * ratio, height: height * ratio)
        return rect
    }
    
    
    func addRotationAnimationToImageView(_ iv : UIImageView, rotation : CGFloat , page : CGFloat){
        let rotationAnimation = RotationAnimation(view : iv)
        rotationAnimation[page] = 0
        rotationAnimation[page + 1] = rotation
        animator.addAnimation(rotationAnimation)
    }
    
    func addRotationAnimationToImageViewIn(_ iv : UIImageView, rotation : CGFloat , page : CGFloat){
        let rotationAnimation = RotationAnimation(view : iv)
        rotationAnimation[page - 1] = 0
        rotationAnimation[page ] = rotation
        animator.addAnimation(rotationAnimation)
    }
    
    
    
    func addVerticalAnimation(_ constraint : NSLayoutConstraint, inValue : CGFloat, outValue: CGFloat, page : CGFloat){
        let verticalAnimation = ConstraintConstantAnimation(superview: scrollView, constraint: constraint)
        verticalAnimation[page - 1] = constraint.constant
        verticalAnimation[page ] = inValue
        verticalAnimation[page + 1 ] = outValue
        animator.addAnimation(verticalAnimation)
    }
    
    //Used for rotation animations going out
    func setupViewMoveOut(_ imageView : UIImageView,x : CGFloat, y : CGFloat, width : CGFloat, height : CGFloat, xDest : CGFloat, yDest : CGFloat, times : [ CGFloat ],  constraints : inout [NSLayoutConstraint], rotation : CGFloat = -90, page : CGFloat = 0 ){
        contentView.addSubview(imageView)
        let exampleProfileY = setupConstraints(imageView, y: y , width: width , height: height , constraints: &constraints)
        keepView(imageView, onPages: [page + calculateCenterXOffset(x , width: width ), page + calculateCenterXOffset(xDest, width: width )], atTimes: times)
        
        addRotationAnimationToImageViewIn(imageView,rotation: rotation, page : 1)
        addVerticalAnimation(exampleProfileY, inValue: calculateCenterYOffset(yDest, height: height),outValue : 0, page : 1)
    }
    
    //Has rotation animations coming in
    func setupViewMoveIn(_ imageView : UIImageView, x : CGFloat, y : CGFloat, width : CGFloat, height : CGFloat, xDest : CGFloat, yDest : CGFloat, yOutDest : CGFloat, xOutDestOffset : CGFloat , times : [ CGFloat ],  constraints : inout [NSLayoutConstraint], rotation : CGFloat = 0, page : CGFloat = 0 ){
        
        // If needed to flip for rotations
        let w = width
        let h = height
        contentView.addSubview(imageView)
        
        let constraintEx = setupConstraints(imageView, y: y , width: w, height: h, constraints: &constraints)
        keepView(imageView, onPages: [page + calculateCenterXOffset( x , width: w ), page +  calculateCenterXOffset(xDest , width: w ), page + xOutDestOffset + calculateCenterXOffset(xDest , width: w )], atTimes : times)
        addRotationAnimationToImageView(imageView,rotation: rotation, page: page )
        
        //addRotationAnimationToImageView(imageView,rotation: rotation, page : page + 1)
        addVerticalAnimation(constraintEx, inValue: calculateCenterYOffset(yDest , height: h), outValue : yOutDest ,page:  page)
        
        let ivFade = AlphaAnimation(view: imageView)
        ivFade[page - 1] = 0
        ivFade[page] = 1
        ivFade[page + 1] = 0
        animator.addAnimation(ivFade)
    }
    
    func setupPage1Constraints() {
        var constraints = [NSLayoutConstraint]()
        
        setupViewMoveIn(commentExample, x: 29, y: 170, width: 181, height: 158, xDest: screenWidth + 400, yDest: 170, yOutDest: 100, xOutDestOffset: 1, times: [0,1,1.5], constraints: &constraints, rotation: 0, page: 0)
        
        //setupViewMoveOut(commentExample, x: 29, y: 170, width: 181, height: 158, xDest: screenWidth + 400, yDest: 100, times: [0,1], constraints: &constraints, rotation: 90, page: 0)
        let commentFade = AlphaAnimation(view: commentExample)
        commentFade[0] = 1
        commentFade[1] = 0
        animator.addAnimation(commentFade)
        
        setupViewMoveOut(profileExample ,x :189, y: 178, width: 163, height: 161, xDest: -400, yDest: 150, times: [0,1], constraints: &constraints)
        
        setupViewMoveOut(swatchesIcon, x: 35, y: 362, width: 47, height: 56, xDest: screenWidth + 400, yDest: 50, times: [0,1], constraints: &constraints, rotation: 90 )
        let swatchesFade = AlphaAnimation(view: swatchesIcon)
        swatchesFade[0] = 1
        swatchesFade[1] = 0
        animator.addAnimation(swatchesFade)
        
        setupViewMoveOut(shelfieExample, x: 107, y: 247, width: 172, height: 215, xDest: -400, yDest: 80, times: [0,1], constraints: &constraints)
        
        setupViewMoveOut(trendingIcon, x: 304, y: 373, width: 28, height: 37, xDest: -550, yDest: 80, times: [0,1], constraints: &constraints,rotation: -135)
        
        setupViewMoveOut(commentIcon, x: 211, y: 143, width: 36, height: 31, xDest: screenWidth + 400, yDest: 300, times: [0,1], constraints: &constraints )
        let commentIconFade = AlphaAnimation(view: commentIcon)
        commentIconFade[0] = 1
        commentIconFade[1] = 0
        animator.addAnimation(commentIconFade)

        let label = createLabel("Experience the world of nails in a fun, unique and beautiful way.", lineHeight: 20)
        contentView.addSubview(label)
        setupConstraints(label, y: 465, width: 247 , height: 90 , constraints: &constraints)
        keepView(label, onPages: [calculateCenterXOffset(64 , width: 247 )])
        
        onboardingContraints.append(constraints)
    }
    
    
    
    func setupPage2Constraints() {
        var constraints = [NSLayoutConstraint]()
        
        setupViewMoveIn(shelfieFlippedExample, x: 424 , y: 147, width: 178 , height: 217, xDest: 34, yDest: 142, yOutDest: -100, xOutDestOffset: 1.5 , times: [0,1,2], constraints: &constraints, rotation: -90, page: 1 )
        
        setupViewMoveIn(selectABrandExample, x: 609, y: 59, width: 126, height: 174, xDest: 216, yDest: 163.47,  yOutDest: 80,xOutDestOffset: -1.5 , times: [0,1,2], constraints: &constraints, rotation: -90, page: 1 )
        
        setupViewMoveIn(coconutExample, x: 473, y: 290, width: 181, height: 178, xDest: 97, yDest: 264,  yOutDest: 80, xOutDestOffset: -1.5 ,times: [0,1,2], constraints: &constraints, rotation: -90, page: 1 )
        
        setupViewMoveIn(heartIcon, x: 408, y: 290, width: 32, height: 29, xDest: 45, yDest: 387,  yOutDest: -50, xOutDestOffset: 1.5 , times: [0,1,2], constraints: &constraints, rotation: -90, page: 1 )
        
        setupViewMoveIn(pinIcon, x: 690, y: 255, width: 24, height: 40, xDest: 297, yDest: 370,  yOutDest: 80, xOutDestOffset: -1.5 ,times: [0,1,2], constraints: &constraints, rotation: -90, page: 1 )
        
        setupViewMoveIn(nailPolishAddIcon, x: 687, y: 171, width: 31, height: 50, xDest: 182, yDest: 191,  yOutDest: 300, xOutDestOffset: -1.5 ,times: [0,1,2], constraints: &constraints, rotation: -90, page: 1 )
        
        setupViewMoveIn(cameraIcon, x: 687, y: 290, width: 52, height: 52, xDest: 162, yDest: 409,  yOutDest: 300, xOutDestOffset: -1.5 ,times: [0,1,2], constraints: &constraints, rotation: -90, page: 1 )
        
        let label = createLabel("Capture and catalog all of your favorite colors!", lineHeight: 23)
        
        contentView.addSubview(label)
        setupConstraints(label, y: 469, width: 230 , height: 90 , constraints: &constraints)
        keepView(label, onPages: [1 + calculateCenterXOffset(63 , width: 230 )])
        
        let labelFade = AlphaAnimation(view: label)
        labelFade[0] = 0
        labelFade[1] = 1
        animator.addAnimation(labelFade)
        
        onboardingContraints.append(constraints)
        
    }
    
    func setupPage3Constraints() {
        var constraints = [NSLayoutConstraint]()
        
        setupViewMoveIn(butterLondonImageExample, x: 442 , y: 106, width: 123, height: 116, xDest: 37, yDest: 134, yOutDest: -80 , xOutDestOffset: 1.5 ,times: [1,2,3], constraints: &constraints, rotation: -90, page: 2 )
        
        setupViewMoveIn(butterLondonIcon, x: 423 , y: 220, width: 94, height: 94, xDest: 62, yDest: 201, yOutDest: -100 , xOutDestOffset: 1.5 ,times: [1,2,3], constraints: &constraints, rotation: -90, page: 2 )
        
        setupViewMoveIn(searchIcon, x: 528 , y: 276, width: 35, height: 36, xDest: 172, yDest: 163, yOutDest: 300 ,xOutDestOffset: 1.5 ,times: [1,2,3], constraints: &constraints, rotation: -90, page: 2 )
        
        setupViewMoveIn(shellacImageExample, x: 607 , y: 171, width: 124, height: 117, xDest: 218, yDest: 134, yOutDest: 100 , xOutDestOffset: -1.5 ,times: [1,2,3], constraints: &constraints, rotation: -90, page: 2 )
        
        setupViewMoveIn(shellacCircleIcon, x: 631 , y: 346, width: 84, height: 84, xDest: 228, yDest: 210, yOutDest: 80 , xOutDestOffset: -1.5 ,times: [1,2,3], constraints: &constraints, rotation: -90, page: 2 )
        
        setupViewMoveIn(clipboardIcon, x: 408 , y: 317, width: 53, height: 58, xDest: 48, yDest: 323,yOutDest: -80 ,xOutDestOffset: 1.5 , times: [1,2,3], constraints: &constraints, rotation: -90, page: 2 )
        
        setupViewMoveIn(julepImageExample, x: 483 , y: 371, width: 115, height: 107, xDest: 133, yDest: 298,yOutDest: -20 , xOutDestOffset: -1.5 ,times: [1,2,3], constraints: &constraints, rotation: -90,page: 2 )
        
        setupViewMoveIn(julepIcon, x: 557 , y: 443, width: 94, height: 94, xDest: 143, yDest: 356,yOutDest: -70 ,xOutDestOffset: -1.5 , times: [1,2,3], constraints: &constraints, rotation: -90, page: 2 )
        
        setupViewMoveIn(noChemicalsIcon, x: 711 , y: 468, width: 48, height: 62, xDest: 278, yDest: 329, yOutDest: 150 ,xOutDestOffset: -1.5 ,times: [1,2,3], constraints: &constraints, rotation: -90, page: 2 )
        
        let label = createLabel("Discover the health rating and important info behind each brand’s colors.", lineHeight: 20)
        
        contentView.addSubview(label)
        setupConstraints(label, y: 458, width: 240 , height: 90 , constraints: &constraints)
        keepView(label, onPages: [2 + calculateCenterXOffset(74 , width: 230 )])
        
        let labelFade = AlphaAnimation(view: label)
        labelFade[1] = 0
        labelFade[2] = 1
        animator.addAnimation(labelFade)
        
        onboardingContraints.append(constraints)
    }
    
    func setupPage4Constraints() {
        var constraints = [NSLayoutConstraint]()
        
        setupViewMoveIn(promoCode, x: 401, y: 121, width: 135, height: 65, xDest: 32, yDest: 164,  yOutDest: 150, xOutDestOffset: 1.5 ,times: [2,3,4], constraints: &constraints, rotation: -90,page: 3 )
        
        setupViewMoveIn(fireworksIcon, x: 544, y: 456, width: 102, height: 78, xDest: 172, yDest: 135,  yOutDest: 150, xOutDestOffset: 1.5 ,times: [2,3,4], constraints: &constraints,rotation: -90, page: 3 )
        
        setupViewMoveIn(applePayIcon, x: 665, y: 124, width: 71, height: 46, xDest: 272, yDest: 190,  yOutDest: 150, xOutDestOffset: 1.5 ,times: [2,3,4], constraints: &constraints, rotation: -90,page: 3 )
        
        setupViewMoveIn(leftProductIcon, x: 401, y: 308, width: 146, height: 170, xDest: 24, yDest: 227,  yOutDest: 150, xOutDestOffset: 1.5 ,times: [2,3,4], constraints: &constraints, rotation: -90, page: 3 )
        
        setupViewMoveIn(rightProduct, x: 687, y: 200, width: 175, height: 173, xDest: 175, yDest: 225,  yOutDest: 150, xOutDestOffset: 1.5 ,times: [2,3,4], constraints: &constraints, rotation: -90, page: 3 )
        
        setupViewMoveIn(centerProductIcon, x: 476, y: 167, width: 193, height: 201, xDest: 92, yDest: 201, yOutDest: 150, xOutDestOffset: 1.5 ,times: [2,3,4], constraints: &constraints, rotation: -90, page: 3 )
        
        setupViewMoveIn(buyNowButtonIcon, x: 619, y: 411, width: 127, height: 39, xDest: 124, yDest: 370,  yOutDest: 150, xOutDestOffset: 1.5 ,times: [2,3,4], constraints: &constraints, rotation: -90, page: 3 )
        
        setupViewMoveIn(applePayIconBlack, x: 430, y: 504, width: 31, height: 23, xDest: 97, yDest: 430,  yOutDest: 150, xOutDestOffset: 1.5 ,times: [2,3,4], constraints: &constraints, rotation: -90, page: 3 )
        
        setupViewMoveIn(visaIcon, x: 493, y: 499, width: 31, height: 23, xDest: 135, yDest: 430,  yOutDest: 150, xOutDestOffset: 1.5 ,times: [2,3,4], constraints: &constraints, rotation: -90, page: 3 )
        
        setupViewMoveIn(amexIcon, x: 423, y: 272, width: 31, height: 23, xDest: 173, yDest: 430,  yOutDest: 150, xOutDestOffset: 1.5 ,times: [2,3,4], constraints: &constraints, rotation: -90, page: 3 )
        
        setupViewMoveIn(discoverIcon, x: 457, y: 546, width: 31, height: 23, xDest: 211, yDest: 430,  yOutDest: 150, xOutDestOffset: 1.5 ,times: [2,3,4], constraints: &constraints, rotation: -90, page: 3 )
        
        setupViewMoveIn(masterCardIcon, x: 627, y: 369, width: 31, height: 23, xDest: 248, yDest: 430, yOutDest: 150, xOutDestOffset: 1.5 ,times: [2,3,4], constraints: &constraints, rotation: -90, page: 3 )
        
        
        let label = createLabel("Buy your favorite colors with a few taps and they’ll be shipped right to you!", lineHeight: 20)
        contentView.addSubview(label)
        setupConstraints(label, y: 457, width: 229 , height: 90 , constraints: &constraints)
        keepView(label, onPages: [3 + calculateCenterXOffset(74 , width: 229 )])
        
        
        let labelFade = AlphaAnimation(view: label)
        labelFade[2] = 0
        labelFade[3] = 1
        animator.addAnimation(labelFade)
        
        onboardingContraints.append(constraints)
    }
    
    func createLabel(_ text : String, lineHeight: Float) -> UILabel{
      
        let lbl = ShelfLabel()
        lbl.text = text
        lbl.kerning = 0.55
        lbl.textColor = UIColor.white
        lbl.lineHeight = lineHeight
        lbl.font = UIFont(name: "Avenir-Black", size: 15)
        lbl.numberOfLines = 0
        return lbl
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        
        let floorValue = floor(scrollView.contentOffset.x/pageWidth)
        pageControl.currentPage = Int(floorValue)
    }
    
    func setupBackgroundWithImage( _ imageNamed : String , screen : CGFloat, constraints : inout [NSLayoutConstraint]){

        
        let backgroundImageView = UIImageView(frame: view.frame)
        backgroundImageView.image = UIImage(named: imageNamed)
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        
        let overlay = UIImageView(frame: backgroundImageView.frame)
        overlay.image = UIImage(named: "BG Ombre - 375")
        overlay.alpha = 0.9
        overlay.contentMode = .scaleAspectFill
        overlay.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
    
        backgroundImageView.addSubview(overlay)
        backgroundImageView.clipsToBounds = true
        

        contentView.backgroundColor = UIColor.shelfPink()
        
        contentView.addSubview(backgroundImageView)
        // NOTE: Designs are in iPhone 6 screen dimensions
        setupConstraints(backgroundImageView, y: 0, width: kiPhone6ScreenWidth, height: kiPhone6ScreenHeight , constraints: &constraints)
        keepView(backgroundImageView, onPages: [0, 1, 2, 3])
        
        let backgroundFade = AlphaAnimation(view: backgroundImageView)
        backgroundFade[screen - 1] = 0
        backgroundFade[screen] = 1
        backgroundFade[screen + 1] = 0
        animator.addAnimation(backgroundFade)

    }

    func setupConstraints(_ childView : UIView, y : CGFloat , width : CGFloat, height : CGFloat, constraints: inout [NSLayoutConstraint]) -> NSLayoutConstraint {
        // NOTE: Calculate ratio for other screen sizes
        let ratioWidth = (view.frame).width / kiPhone6ScreenWidth
        let ratioHeight = (view.frame).height / kiPhone6ScreenHeight
        
        let centerY = NSLayoutConstraint(item: childView, attribute: .centerY, relatedBy:
            .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: calculateCenterYOffset(y * ratioHeight, height: ratioHeight * height))
        let widthConstraint = NSLayoutConstraint(item: childView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width * ratioWidth)
        
        let heightConstraint = NSLayoutConstraint(item: childView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height * ratioHeight)
        
        constraints.append(centerY)
        
        NSLayoutConstraint.activate([centerY, widthConstraint, heightConstraint])
        
        return centerY
    }
    
    // MARK: - Facebook Login Helper Functions
    func getDetailsAndLogin() {
        if logging {
            return
        }
        logging = true
        requestFacebook()
        
    }
    
    func logoutFacebook() {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        logging = false
        
    }
    
    func requestFacebook() {
        let progress = MBProgressHUD.showAdded(to: self.view, animated: true)
        progress.labelText = "Logging In"
        
        let request = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, first_name, last_name, picture.type(large), email, cover.type(large)"])
		request?.start(completionHandler: { (connection, result1, error) in
            print("result: \(result1)")
            if error == nil && result1 != nil {
				let result = result1 as! [String: String?]
				
                if let firstName = result["first_name"],
                    let lastName = result["last_name"],
                    let email = result["email"] {
                    self.loginFBParse(firstName!, lastName: lastName!, email: email!, result: result as AnyObject)
                }
                else {
                    self.logoutFacebook()
                    self.presentFBLoginErrorAlert()
                }
            }
            else {
                self.presentFBLoginErrorAlert()
            }
        })
    }
    
    func queryExistingNonFBUser(_ email: String, result: AnyObject) {
        if let query = PFUser.query() {
            query.whereKey("email", equalTo: email)
            query.whereKeyDoesNotExist("authData")
			
			query.countObjectsInBackground(block: { (count, error) in
                if error == nil {
                    print("count: \(count)")
                    if count > 0 {
                        let message = "The email address \(email) has already been taken. Please Login with your existing email and password."
                        let alertC = UIAlertController(title: "Facebook Login Error", message: message, preferredStyle: .alert)
                        alertC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alertC, animated: true, completion: nil)
                        
                        self.logoutFacebook()
                        // Parse creates a new user with PFFacebookUtils that needs to be deleted.
                        do {
                            try PFUser.current()?.delete()
                        } catch {
                            
                        }
                        PFUser.logOut()
                        MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    }else {
                        if let currentUser = PFUser.current() {
                            currentUser.email = email
                            self.saveProfilePic(result)
                        }
                        else {
                            self.presentFBLoginErrorAlert()
                            self.logoutFacebook()
                            PFUser.logOut()
                        }
                    }
                }
                else {
                    self.logoutFacebook()
                    PFUser.logOut()
                    self.presentFBLoginErrorAlert()
                }
            })
        }
        //
        else {
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
        }
    }
    
    func loginFBParse(_ firstName: String, lastName: String, email: String, result: AnyObject) {
		PFFacebookUtils.logInInBackground(with: FBSDKAccessToken.current()) { (user, error) in
            if error == nil && user != nil {
                if let currentUser = PFUser.current() {
                    currentUser["firstName"] = firstName
                    currentUser["lastName"] = lastName
                    currentUser["searchText"] = firstName.lowercased() + lastName.lowercased() + email.lowercased()
                    
                    // Check if existing FB user
                    if let _ = currentUser.email {
                        currentUser.email = email
                        self.saveProfilePic(result)
                    }
                    // New FB User, query to see if email exists for another account
                    else {
                        self.queryExistingNonFBUser(email, result: result)
                    }
                    
                }
                else {
                    self.presentFBLoginErrorAlert()
                    self.logoutFacebook()
                    PFUser.logOut()
                }
            }
            else {
                self.presentFBLoginErrorAlert()
                self.logoutFacebook()
                print("error occurred while signing in ")
                print(error)
            }
        }
    }
    
    func saveProfilePic(_ result: AnyObject) {
        if let profilePic = result.object(forKey: "picture")?.object(forKey: "data")?.object(forKey: "url") as? String {
            let imageData = try? Data(contentsOf: URL(string: profilePic)!)
            let compressedImage = compressImage(UIImage(data: imageData!)!)
            
            let picFile = PFFile(name: "profilePic.jpg", data: UIImageJPEGRepresentation(UIImage(data: compressedImage)!, 1.0)!)
			
			picFile?.saveInBackground(block: { (success, error) in
                if error == nil && success == true {
                    if let currentUser = PFUser.current() {
                        currentUser["image"] = picFile
                    }
                    self.saveCoverPic(result)
                }
                else {
                    self.presentFBLoginErrorAlert()
                    self.logoutFacebook()
                }
            })
        }
        // No FB profile picture url
        else {
            self.saveCoverPic(result)
        }
    }
    
    func saveCoverPic(_ result: AnyObject) {
        if let coverPic = result.object(forKey: "cover")?.object(forKey: "source") as? String {
            let imageDataCover = try? Data(contentsOf: URL(string: coverPic)!)
            
            let compressedImage = compressImage(UIImage(data: imageDataCover!)!)
            let coverFile = PFFile(name: "coverPic.jpg", data: UIImageJPEGRepresentation(UIImage(data: compressedImage)!, 1.0)!)
			
			coverFile?.saveInBackground(block: { (success, error) in
                if error == nil && success == true {
                    if let currentUser = PFUser.current() {
                        currentUser["coverImage"] = coverFile
                    }
                    self.saveCurrentUser()
                }
                else {
                    self.presentFBLoginErrorAlert()
                    self.logoutFacebook()
                }
            })
        }
        // No FB cover picture url
        else {
            self.saveCurrentUser()
        }
    }
    
    func saveCurrentUser() {
        if let currentUser = PFUser.current() {
            self.addVersionToUser(currentUser)
			currentUser.saveInBackground(block: { (success, error) in
                guard error == nil && success == true else {
                    self.presentFBLoginErrorAlert()
                    self.logoutFacebook()
                    PFUser.logOut()
                    return
                }
                
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                // Facebook username has been updated, transition to Home directly
                if let hasUpdatedUsername = currentUser.object(forKey: "hasUpdatedUsername") as? Bool, hasUpdatedUsername == true {
                    SFollow.refreshFollowing()
                    SFollow.refreshFollowers()
                    AnalyticsHelper.sendCustomEvent(kFIREventLogin)
                    let sb = UIStoryboard(name: "Main", bundle: nil)
                    let vc = sb.instantiateViewController(withIdentifier: "HomeTBC") as! CustomTabbarController
                    self.present(vc, animated: true, completion: nil)
                }
                // Facebook username has not been updated, transition to Username Entry VC
                else {
                    let userNameEntry = self.storyboard?.instantiateViewController(withIdentifier: "UserNameEntryVC") as! UserNameEntryVC
                    userNameEntry.user = currentUser
                    self.navigationController?.pushViewController(userNameEntry, animated: true)
                }
            })
        }
        // No current PFUser
        else {
            self.presentFBLoginErrorAlert()
            self.logoutFacebook()
            PFUser.logOut()
        }
    }
    
    func addVersionToUser(_ user : PFUser ) {
        //Adds in app version
        let version: AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject?
        if let versionString = version as? String {
            if let appVersionString = user["AppVersion"] as? String {
                if versionString.compare(appVersionString, options: NSString.CompareOptions.numeric) == ComparisonResult.orderedDescending  {
                    user["AppVersion"] = versionString
                }
            }
            else if user["AppVersion"] as? String == nil {
                user["AppVersion"] = versionString
            }
            print(user["AppVersion"])
        }
    }

    func presentFBLoginErrorAlert() {
        MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
        let alertC = UIAlertController(title: "Facebook Login Error", message: "Error occurred while signing in with Facebook, please try again.", preferredStyle: .alert)
        alertC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertC, animated: true, completion: nil)
    }
}
