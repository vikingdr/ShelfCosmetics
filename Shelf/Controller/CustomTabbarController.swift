//
//  CustomTabbarController.swift
//  Shelf
//
//  Created by Nathan Konrad on 29/05/15.
//  Copyright (c) 2015 Shelf. All rights reserved.
//

import UIKit

class CustomTabbarController: UITabBarController, UITabBarControllerDelegate {
    var previousVC :UIViewController?
    
    override func viewDidLoad() {
        self.delegate = self
        previousVC = self.selectedViewController
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "Navigationbar"), forBarMetrics: UIBarMetrics.Default)
    }
    
    override func viewWillLayoutSubviews() {
        var tabFrame: CGRect = self.tabBar.frame
        tabFrame.size.height = 44
        tabFrame.origin.y = self.view.frame.size.height - 44
        self.tabBar.frame = tabFrame
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        appDelegate.imagefooter?.hidden = false
        let index : NSInteger? = self.selectedIndex
        
        if (index == 2) {
            let addVC: UIViewController = UIStoryboard(name: "CreateShelfie", bundle: nil).instantiateViewController(withIdentifier: "CameraOverlayVC")
            addVC.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
            self.present(addVC, animated: true, completion: nil)
        }
        
        self.setupFrameForFooterSelectionView(index!)
    }
	
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let array : NSArray? = tabBarController.viewControllers as NSArray?
        let index : NSInteger? = array?.index(of: viewController)
        
        if (index == 2) {
            
            let addVC: UIViewController = UIStoryboard(name: "CreateShelfie", bundle: nil).instantiateViewController(withIdentifier: "CameraOverlayVC") 
            addVC.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
            let navController = NickNavViewController(rootViewController: addVC)
            self.present(navController, animated:true, completion: nil)
            return false
            
        }
        
        // Adding slide animation of tabbar current controller changing
        let tabViewControllers = tabBarController.viewControllers! as NSArray
        
        let fromView = tabBarController.selectedViewController!.view
        let toView = viewController.view
        
        if fromView != toView {
            
            let fromIndex = tabViewControllers.index(of: tabBarController.selectedViewController!)
            let toIndex = tabViewControllers.index(of: viewController)

            CATransaction.begin()
            
            CATransaction.setAnimationDuration(0.2)
            
            let transition = CATransition()
            transition.type = kCATransitionPush
            if fromIndex < toIndex {
                transition.subtype = kCATransitionFade
            } else {
                transition.subtype = kCATransitionFade
            }
            
            fromView?.superview!.superview!.layer.add(transition, forKey: kCATransition)
            tabBarController.selectedIndex = toIndex;
            
            
            //Toolbar is setup using single image... so we need to do this unfortunately...
            let index = toIndex + 1
            if constant.DeviceType.IS_IPHONE_6P  {
                appDelegate.imagefooter?.image = UIImage(named: "Tab_strip_\(index)_iPhone6plus@3x")
            }
            else if constant.DeviceType.IS_IPHONE_6 {
                appDelegate.imagefooter?.image = UIImage(named: "Tab_strip_\(index)_iPhone6@2x")
            }
            else if constant.DeviceType.IS_IPHONE_5 {
                appDelegate.imagefooter?.image = UIImage(named: "Tab_strip_\(index)_iPhone5@2x")
            }
            else if constant.DeviceType.IS_IPHONE_4_OR_LESS {
                appDelegate.imagefooter?.image = UIImage(named: "Tab_strip_\(index)@2x")
            }
            
            CATransaction.commit()
 
        }
        
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController){
        if(previousVC == viewController) {
            
            let array : NSArray? = tabBarController.viewControllers as NSArray?
            let index : NSInteger? = array?.index(of: viewController)
            
            switch (index!) {
            case 0 :
                
                let navController = viewController as! UINavigationController
                let homeVC = navController.viewControllers[0] as! HomeViewController
                homeVC.tableview?.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
                
            case 1 :
                
                let navController = viewController as! UINavigationController
                let searchVC = navController.viewControllers[0] as! SearchViewController
                searchVC.collectionView?.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
                searchVC.searchPeopleVC?.tableView?.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
                
            case 3 :
                
                let navController = viewController as! UINavigationController
                let notificationVC = navController.viewControllers[0] as! TrendingVC
                notificationVC.collectionView?.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
                
            default:
                
                let navController = viewController as! UINavigationController
                let profileVC = navController.viewControllers[0] as! MyProfileVC
                profileVC.collectionView?.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
            }
        }
        previousVC = viewController
    }
    
    // MARK: - Tabs switch
    
    func setupFrameForFooterSelectionView (_ toIndex : Int) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        switch (toIndex) {
        case 0, 4 :
            appDelegate.footerSelectionView?.left   = constant.ScreenSize.SCREEN_WIDTH / 5 * CGFloat(toIndex)
            appDelegate.footerSelectionView?.width  = constant.ScreenSize.SCREEN_WIDTH / 5
            break
        case 1 :
            appDelegate.footerSelectionView?.left   = constant.ScreenSize.SCREEN_WIDTH / 5 * CGFloat(toIndex)
            appDelegate.footerSelectionView?.width  = constant.ScreenSize.SCREEN_WIDTH / 5 + 7
            break
        case 3 :
            appDelegate.footerSelectionView?.left   = constant.ScreenSize.SCREEN_WIDTH / 5 * CGFloat(toIndex) - 7
            appDelegate.footerSelectionView?.width  = constant.ScreenSize.SCREEN_WIDTH / 5 + 7
            break
        default :
            NSLog("tabBarController shouldSelectViewController : strange error")
        }
    }
    
}
