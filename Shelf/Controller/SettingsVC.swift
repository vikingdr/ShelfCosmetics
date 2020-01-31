//
//  SettingsVC.swift
//  Shelf
//
//  Created by Nathan Konrad on 06/06/15.
//  Copyright (c) 2015 Shelf. All rights reserved.
//

import UIKit

let kSettingsVCIdentifier = "SettingsVC"

class SettingsVC: BaseVC {

    @IBOutlet var tblSettings : UITableView!
    
    var arrayimgSettings: [(imageName:String,labelText:String)] = []
    var isAddFriend: Bool = false
    
    // MARK: - View Life Cycle Methods
    override func viewDidLoad() {
        
        arrayimgSettings = [
            (imageName:"editProfileIcon",labelText:"Edit Profile"),
            (imageName:"shoppingCartIcon",labelText:"Shopping Cart"),
            (imageName:"orderHistoryIcon",labelText:"Order History"),
            (imageName:"addEditPaymentIcon",labelText:"Add/Edit Payment"),
            (imageName:"trackingInfoIcon",labelText:"Shipping Address"),
            (imageName:"removeShelfiesIcon",labelText:"Remove SHELFIES"),
            (imageName:"shelfiesIveLikedIcon",labelText:"SHELFIES I've Liked"),
            (imageName:"helpCenterIcon",labelText:"Help Center"),
            (imageName:"termsIcon",labelText:"Terms & Conditions"),
            (imageName:"logoutIcon",labelText:"Log Out")
        ]
        
        setupNavigationBar()
        setupTableView()
    }
    
    // MARK: - Setup helper functions
    override func setupNavigationBar() {
        super.setupNavigationBar()
        title = "Settings"
        
        if isAddFriend {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "invitefb"), style: .plain, target: self, action: #selector(addFriendPressed))
            navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        }

    }
    
    func addFriendPressed() {
        
    }
    
    func setupTableView() {
        tblSettings.register(UINib(nibName: kSettingsCellIdentifier, bundle: nil), forCellReuseIdentifier: kSettingsCellIdentifier)
        tblSettings.backgroundColor = UIColor.clear
        tblSettings.backgroundView = nil
        tblSettings.contentInset = UIEdgeInsetsMake(25, 0, 50, 0)
    }
    
    override func backPressed() {
        
        if isAddFriend {
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromRight
            view.window!.layer.add(transition, forKey: kCATransition)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - IBAction
    @IBAction func settingsButtonPressed(_ sender:UIButton) {
        var storyboard: UIStoryboard = UIStoryboard(name: "Settings", bundle: nil)
        switch(sender.tag) {
            case 0:
                let vc = storyboard.instantiateViewController(withIdentifier: "MyProfileEditVC") as? MyProfileEditVC
                self.navigationController?.pushViewController(vc!, animated: true)
                break
            
            case 1:
                storyboard = UIStoryboard(name: "ECommerce", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "ShoppingCartVC") as? ShoppingCartVC
                self.navigationController?.pushViewController(vc!, animated: true)
                break
            
            // Order History
            case 2:
                let vc = storyboard.instantiateViewController(withIdentifier: kOrderHistoryVCIdentifier) as? OrderHistoryVC
                self.navigationController?.pushViewController(vc!, animated: true)
                break
            
            // Add/Edit Payment
            case 3:
                storyboard = UIStoryboard(name: "ECommerce", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "AddEditPaymentVC") as? AddEditPaymentVC
                self.navigationController?.pushViewController(vc!, animated: true)
                break
            
            // Shipping Address
            case 4:
                storyboard = UIStoryboard(name: "ECommerce", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: kAddressInfoVCIdentifier) as! AddressInfoVC
                vc.confirmShippingAddressFromSettings = shippingAddressUpdated
//                vc.isSettingsShipping = true
//                
//                if let shipping = ShippingManager.sharedInstance.shipping {
//                    vc.shippingSettings = shipping
//                }
                
                self.navigationController?.pushViewController(vc, animated: true)
                break
            
            // Remove Shelfies
            case 5:
                let vc = storyboard.instantiateViewController(withIdentifier: "EditYourColorsVC") as? EditYourColorsVC
                self.navigationController?.pushViewController(vc!, animated: true)
                break
            
            // Shelfies I've Liked
            case 6:
                let vc = storyboard.instantiateViewController(withIdentifier: "ColorsYouLikedVC") as? ColorsYouLikedVC
                self.navigationController?.pushViewController(vc!, animated: true)
                break
            
            // Help Center
            case 7:
                let vc = storyboard.instantiateViewController(withIdentifier: "HelpCenterVC") as! HelpCenterVC
                self.navigationController?.pushViewController(vc, animated: true)
                break
            
            // Terms & Conditions
            case 8:
                let legalJargonVC = storyboard.instantiateViewController(withIdentifier: "LegalJargonVC") as? LegalJargonVC
                legalJargonVC?.type = LegalViewType.termsAndConditions
                navigationController?.pushViewController(legalJargonVC!, animated: true)
                break
            
            // Log Out
            default:
                print("Logout pressed")
                let loginManager = FBSDKLoginManager()
                loginManager.logOut()
                FBSDKAccessToken.setCurrent(nil)
                
                PFUser.logOut()
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.showSplash = false
                appDelegate.showMenu()
        }
    }

    // MARK: - Callback functions
    func shippingAddressUpdated() {
        
    }
}

extension SettingsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayimgSettings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: kSettingsCellIdentifier, for: indexPath) as! SettingsCell
        cell.settingsButton.tag = indexPath.row
        cell.settingsButton.addTarget(self, action: #selector(SettingsVC.settingsButtonPressed(_:)), for: .touchUpInside)
        cell.updateWithData(arrayimgSettings[indexPath.row].imageName, labelText: arrayimgSettings[indexPath.row].labelText)
        
        return cell
    }
}
