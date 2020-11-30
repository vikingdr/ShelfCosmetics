//
//  ViewControllerExtension.swift
//  Shelf
//
//  Created by Matthew James on 10/14/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func presentParseUserError(){
        let alertC = UIAlertController(title: "Please log back in", message: "We just resolved an issue", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default) { (action) in
            PFUser.logOut()
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.showSplash = false
            appDelegate.showMenu()
        }
        
        alertC.addAction(okButton)
        present(alertC,animated : true, completion : nil)
    }
    
    func presentErrorDialog( _ errorCode : Int?, reason : String = "with the address information") {
        AppDelegate.hideActivity()
        var errString = ""
        if let errorCode = errorCode {
            errString = "(\(errorCode))"
        }
        let alertC = UIAlertController(title: "Error", message: "The error \"\(reason)\" has occurred, please try again later. \(errString)", preferredStyle: .alert)
        let returnToParent =  UIAlertAction(title: "OK", style: .default) { (action) in
            //self.navigationController?.popViewControllerAnimated(true)
        }
        alertC.addAction(returnToParent)
        self.present(alertC, animated: true, completion: nil)
    }
    
    func presentWarningDialog(title: String, message: String) {
        AppDelegate.hideActivity()
        let alertC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertC.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
            
        }))
        self.present(alertC, animated: true, completion: nil)
    }
    
    func transitionToProfile(_ user : SUser?, isFollowing: Bool? = nil, completion: (() -> Void)? = nil) {
        guard let user = user, let currUser = PFUser.current(), user.objectId != currUser.objectId else {
            return
        }
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: ProfileVC = storyboard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        vc.user = user
        vc.isFollowing = isFollowing
        let navController = NickNavViewController(rootViewController: vc)
        self.present(navController, animated:true, completion: completion)
    }
    
    func setupBackButton(){
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 18))
        backButton.setImage(UIImage(named: "backButton"), for: UIControlState())
        backButton.addTarget(self, action: #selector(UIViewController.backPressed), for: .touchUpInside)
        let backButtonItem = UIBarButtonItem(customView: backButton)
        backButtonItem.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = backButtonItem
    }
    
    func addBackButtonToView(){
        let backButton = UIButton(frame: CGRect(x: 27, y: 56, width: 10, height: 18))
        backButton.setImage(UIImage(named: "backButton"), for: UIControlState())
        backButton.addTarget(self, action: #selector(UIViewController.backPressed), for: .touchUpInside)
        self.view.addSubview(backButton)
    }
    
    func backPressed(){
        dismiss(animated: true, completion: nil)
    }
    
    func addProgressToNavBar(_ imageName : String ) -> UIImageView{
        let navBar = self.navigationController?.navigationBar
        let image = UIImage(named: imageName)!.resizableImage(withCapInsets: UIEdgeInsetsMake(0, 0, 0, 0), resizingMode: .stretch)
        
        let navBarHeight = navBar!.frame.size.height
        let navBarWidth = navBar!.frame.size.width
        let imageViewWidth = CGFloat(251)
        let imageViewHeight = CGFloat(28)
        let imageView = UIImageView(frame: CGRect(x: (navBarWidth - imageViewWidth) / 2 , y: (navBarHeight - imageViewHeight) - 11, width: imageViewWidth, height: imageViewHeight  ))
        imageView.image = image
        navBar?.addSubview(imageView)
        return imageView
    }
    
    func getDeviceBackgroundImageName(_ imageName: inout String) {
        if constant.DeviceType.IS_IPHONE_4_OR_LESS {
            imageName += " - 4"
        }
        else if constant.DeviceType.IS_IPHONE_5 {
            imageName += " - 5"
        }
    }
}
