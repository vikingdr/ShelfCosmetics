
//  AppDelegate.swift
//  Shelf
//
//  Created by Nathan Konrad on 29/04/15.
//  Copyright (c) 2015 Shelf. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import Stripe
import ParseFacebookUtilsV4
import Firebase
import ROKOMobi
import AFNetworking

let kInvalidSessionTokenNotification = "Invalid Session Token Notification"

private var activity : UIActivityIndicatorView!
let kIsDeactivated = "isDeactivated"
let kMessage = "message"

let kConversionKey = "f83275c3e502f6b9ed4104a6b3610df1"
let kAdvertiserId = "192811"

// Nathan Konrad Shelf Dev
let PARSE_APPLICATION_ID = "VI83dXAsZZ9rrzgtSooRZKneJzEw5DWGzADudQLQ"
let PARSE_CLIENT_KEY = "J0YzH19ka9lwQ53WE0yJDCqrDCgrlYjQeoTcjHu8"

//Shelf keys
//let PARSE_APPLICATION_ID = "CkF4mGr8BE1z7UAYT2iTlX7qPVi09xQCtV2x1033"
//let PARSE_CLIENT_KEY = "2uVk7jA1iTJC9SN3jsu15OmrU4LjpOKIPo1S3ugL"

//Shopify Constants
let kShopifyDomain = "shelf-cosmetics.myshopify.com"
let kShopifyAPIKey = "7c03863b16e5dff0051fc5ddcf66f6de"
let kShopifyAppId = "8"

//Stripe Test
let kTestPublishableKey = "pk_test_l63ZQ7Jj7Tgs8Ebxo39pcgmQ"
let kLivePublishableKey = "pk_live_3JM7YY0GWcMziD1ShWR62X1v"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var imagefooter : UIImageView?
    var footerSelectionView : UIView?

    var linkManager : ROKOLinkManager!

    var showSplash = true
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        imagefooter = UIImageView()

       // manager.requestSerializer.setAuthorizationHeaderFieldWithUsername(kShelfUsername, password: kShelfPassword
        
        // Stripe
        STPPaymentConfiguration.shared().publishableKey = kTestPublishableKey
        
        
        //back4apps
        let configuration = ParseClientConfiguration {
            
            $0.applicationId = "CkF4mGr8BE1z7UAYT2iTlX7qPVi09xQCtV2x1033"
            $0.clientKey = "2uVk7jA1iTJC9SN3jsu15OmrU4LjpOKIPo1S3ugL"
            $0.server = "https://parseapi.back4app.com"
            $0.isLocalDatastoreEnabled = true // If you need to enable local data store
            
        }
        Parse.initialize(with: configuration)
        PFFacebookUtils.initializeFacebook(applicationLaunchOptions: launchOptions)
        

//        // Parse
//        Parse.enableLocalDatastore()
//        PFUser.enableRevocableSessionInBackground()
//        Parse.setApplicationId(PARSE_APPLICATION_ID, clientKey: PARSE_CLIENT_KEY)
//        PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions, block: nil)
//        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        // =====================================================================
        
        // Roko Mobi
        linkManager = ROKOLinkManager()
        linkManager.delegate = self
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        if PFUser.current() == nil {
            self.showMenu()
        }
        else {
            self.showContent()
            let portalManager = ROKOComponentManager.shared().portalManager()
            
            if let email = PFUser.current()?.email {
                portalManager?.setUserWithName(email, referralCode: nil, linkShareChannel: nil, completionBlock: { (error) in
                    print("ROKO Setup error \(error)")
                })
            }
        }
        
        // Fabric Crashlytics
//      Fabric.with([Crashlytics.self()])
//        window?.makeKeyAndVisible()
        
        // Firebase
        FIRApp.configure()

        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.presentInvalidSessionTokenError(_:)), name: NSNotification.Name(rawValue: kInvalidSessionTokenNotification), object: nil)
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        linkManager.continue(userActivity)
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        linkManager.handleDeepLink(url)
        if #available(iOS 9.0, *) {
            return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        } else {
            return true
        }
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {

        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func applicationWillResignActive(_ application: UIApplication) {
       
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        SFollow.refreshFollowing()
        SFollow.refreshFollowers()
        
        // reset the navigation bar on feed
        if (self.window?.rootViewController?.isKind(of: CustomTabbarController.self) != nil) {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "BringNavigationBarToOriginal"), object: nil)
        }
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func showMenu() {
        if let subviews = window?.subviews {
            subviews.forEach({ $0.removeFromSuperview() })
        }

        let storyboard:UIStoryboard = UIStoryboard(name: "Login", bundle: nil)        
        let nc = storyboard.instantiateViewController(withIdentifier: "OnboardingNC") as! UINavigationController

        /*
        // UserDefaults NOT nil
        if let onboardingSeen = NSUserDefaults.standardUserDefaults().objectForKey(kKeyOnboardingSeen) as? Bool {
            // OnboardingSeen is equal true, update to show MenuVC
            if onboardingSeen == true {
                let vc = storyboard.instantiateViewControllerWithIdentifier(kMenuVCIdentifier)
                nc.viewControllers = [vc]
            }
            // OnboardingSeen is equal false, show OnboardingVC (Currently app does have support for setting OnboardingSeen to false)
            else {
                // Do Nothing
            }
        }
        // UserDefaults nil, show OnboardingVC
        else {
            // Do Nothing
        }
 */

        window?.rootViewController = nc
		
		window?.makeKeyAndVisible()
    }
    
    func showContent() {
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let subviews = window?.subviews {
            subviews.forEach({ $0.removeFromSuperview() })
        }
        SFollow.refreshFollowers()
        SFollow.refreshFollowing()
        window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "HomeTBC")
		
		window?.makeKeyAndVisible()
    }
    
    //MARK: - global activity Indicator
    class var shared : AppDelegate {
        get {
            return UIApplication.shared.delegate as! AppDelegate
        }
    }
    
    class func showActivity() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        DispatchQueue.main.async(execute: {
            delegate.window!.addSubview(self.activityIndicator())
            self.activityIndicator().startAnimating()
        })
    }
    
    class func hideActivity() {
        DispatchQueue.main.async(execute: {
            self.activityIndicator().removeFromSuperview()
            self.activityIndicator().stopAnimating()
        })
    }
    
    class func activityIndicator() -> UIActivityIndicatorView {
        if activity == nil {
            let delegate = UIApplication.shared.delegate as! AppDelegate
            activity = UIActivityIndicatorView(frame: delegate.window!.bounds)
            activity.backgroundColor = UIColor(white: 0, alpha: 0.3)
            activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        }
        return activity
    }


    // MARK: - NSNotification
    func presentInvalidSessionTokenError(_ notification: Notification) {
        guard let window = window, let rootVC = window.rootViewController else {
            return
        }
        
        let alertC = UIAlertController(title: "Please log back in", message: "We just resolved an issue", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default) { (action) in
            PFUser.logOut()
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            self.showSplash = false
            self.showMenu()
        }
        
        alertC.addAction(okButton)
        rootVC.present(alertC,animated : true, completion : nil)
    }
}

extension AppDelegate : ROKOLinkManagerDelegate {
    func linkManager(_ manager: ROKOLinkManager, didOpenDeepLink link: ROKOLink) {
        
    }
    
    func linkManager(_ manager: ROKOLinkManager, didFailToOpenDeepLinkWithError error: NSError?) {
        
    }
}

