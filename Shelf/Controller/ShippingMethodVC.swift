//
//  ShippingMethodVC.swift
//  Shelf
//
//  Created by Nathan Konrad on 10/26/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation
import Buy
let kShippingMethod = "shippingMethodModel"
let kShippingModel = "shippingNonBillingModel"

let kShippingMethodIdentifier = "ShippingMethodVC"

class ShippingMethodVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var continueButtonView: UIView!
    @IBOutlet weak var continueButton: ShelfButton!
    @IBOutlet weak var saveForLaterSwitch: UISwitch!
    
    var shippingOptions: [ShippingOption] = [ShippingOption]()
    var selectedIndexPath = IndexPath(row: 0, section: 0)
    var isSaveEnabled : Bool = true
    var model : ShippingMethodModel!
    var order : CurrentOrder!
    
    var confirmShippingMethodFromReviewOrder : ((ShippingMethodModel) -> ())?
    
    var enterNewAddressButton : UIButton?
    var newShippingInfo : AddressInfoModel?
    var shouldUseBilling = true
    var progressImageView : UIImageView?
    var selectedShippingRate : BUYShippingRate?
    var buyPaymentToken : BUYPaymentToken?
    
    override func viewDidLoad() {
        let attr = [NSFontAttributeName: UIFont(name: "Avenir-Black", size: 16)!,
                    NSForegroundColorAttributeName: UIColor.white,
                    NSKernAttributeName: 0.53] as [String : Any]
        navigationController?.navigationBar.titleTextAttributes = attr
        
        let emptyButton = UIButton(frame: CGRect(x: 0, y: 0, width: 17, height: 17))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: emptyButton)
  
        if model == nil {
            let defaults = UserDefaults.standard
            if let savedModel = defaults.object(forKey: kShippingMethod) as? Data{
                model = NSKeyedUnarchiver.unarchiveObject(with: savedModel) as! ShippingMethodModel
                tableView.reloadData()
            } else {
                model = ShippingMethodModel()
            }
        }
        
        setupTableView()
        setupBottomBar()
        
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 18))
        backButton.setImage(UIImage(named: "backButton"), for: UIControlState())
        backButton.addTarget(self, action: #selector(ShippingMethodVC.backButtonPressed(_:)), for: .touchUpInside)
        let backButtonItem = UIBarButtonItem(customView: backButton)
        backButtonItem.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = backButtonItem
        
        continueButton.isEnabled = false
        
        // Check if there are shipping rates available
        if let shippingRates = BUYCheckoutManager.sharedInstance.shippingRates {
            addShippingOptions(shippingRates)
            self.tableView.reloadData()
        }
        // Fetch Shipping Rates
        else {
            fetchShippingRates()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        progressImageView = addProgressToNavBar("ProgressBarShipping")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let progressImg = progressImageView {
            progressImg.removeFromSuperview()
            
        }
    }

    // MARK: - Setup helper functions
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 69, 0)
        tableView.register(UINib(nibName: "ShippingMethodCell", bundle: nil), forCellReuseIdentifier: "ShippingMethodCell")
        tableView.register(UINib(nibName: "ShippingAddressSameAsCell", bundle: nil), forCellReuseIdentifier: "ShippingAddressSameAsCell")
        
        tableView.register(UINib(nibName: "SelectAShippingMethodCell", bundle: nil), forCellReuseIdentifier: "SelectAShippingMethodCell")
        
        tableView.separatorColor = UIColor.clear
        tableView.estimatedRowHeight = 103
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func setupBottomBar() {
        if let _ = confirmShippingMethodFromReviewOrder {
            continueButton.updateAttributedTextWithString("CONFIRM SHIPPING METHOD", forState: UIControlState())
        }
        
        continueButtonView.roundAndAddDropShadow(8, shadowOpacity: 0.15, width: 0, height: 1, shadowRadius: 1)
        continueButton.setBackgroundColor(UIColor.init(white: 1, alpha: 0.3), forState: .highlighted)
        continueButton.layer.cornerRadius = 8
        continueButton.layer.masksToBounds = true
        saveForLaterSwitch.isOn = isSaveEnabled
    }
    
    // MARK: - IBAction
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func continueReviewPurchase(_ sender: AnyObject) {
        if shouldUseBilling == false && newShippingInfo != nil{
            order.shippingInfo = newShippingInfo
        }
        else {
            order.shippingInfo = order.creditCard?.billingAddress
        }
        
//        if presentModal == true {
        
        
        // NOTE: Since there's only 1 shipping method, return back to Review Order imitating user has updated Shipping Method
        if let confirmShippingMethodFromReviewOrder = confirmShippingMethodFromReviewOrder {
            confirmShippingMethodFromReviewOrder(model)
            navigationController?.popViewController(animated: true)
            return
        }
//            self.dismissViewControllerAnimated(true, completion: nil)
//        }
        
        if isSaveEnabled == true {
            CreditCardManager.sharedInstance.updateAddPayment(order.creditCard!)
        }
        
        order.shippingMethodInfo = model
        
        if let selectedShippingRate = selectedShippingRate {
            BUYCheckoutManager.sharedInstance.updateCheckoutWithShippingRate(selectedShippingRate) { (checkout: BUYCheckout?, error: NSError?) in
                guard error == nil, let _ = checkout else {
                    // Display ERROR Alert
                    self.presentErrorDialog(error?.code)
                    return
                }
                
                let vc: ReviewOrderVC = self.storyboard?.instantiateViewController(withIdentifier: kReviewOrderVCIdentifier) as! ReviewOrderVC
                vc.order = self.order
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func saveInfoForLaterValueChanged(_ switchState: UISwitch) {
        isSaveEnabled = !isSaveEnabled
    }
    
    override func backPressedModal() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func enterNewAddressPressed() {
        let vc = storyboard?.instantiateViewController(withIdentifier: kAddressInfoVCIdentifier) as! AddressInfoVC
        vc.confirmShippingAddressFromShippingMethod = updateShippingAddress
//        vc.isShipping = true
//        vc.isSettingsShipping = true
//        vc.shippingSettings = ShippingManager.sharedInstance.shipping
//        vc.updateShippingAddress = updateShippingAddress
        navigationController?.pushViewController(vc, animated: true)
//        let nc = UINavigationController(rootViewController: vc)
//        navigationController?.presentViewController(nc, animated: true, completion: nil)
    }
    
    func shippingSameAsBillingValueChanged(_ switchControl : UISwitch) {
        if enterNewAddressButton != nil {
            if switchControl.isOn == false {
                shouldUseBilling =  false
                enterNewAddressButton?.isEnabled = true
                enterNewAddressButton?.isHidden = false
            } else{
                shouldUseBilling = true
                enterNewAddressButton?.isEnabled = false
                enterNewAddressButton?.isHidden = true
            }
        }
    }
    
    // MARK: - Helper functions
    fileprivate func fetchShippingRates() {
        AppDelegate.showActivity()
        BUYCheckoutManager.sharedInstance.getShippingRates({ (error: NSError?, rates: [BUYShippingRate]?) in
            AppDelegate.hideActivity()
            guard error == nil, let rates = rates else {
                // Display ERROR Alert
                var errorMessage = "Get shipping rates failed"
                if let error = error {
                    print("getShippingRates error: \(error)")
                    errorMessage = ShopifyErrorParser.sharedInstance.getCheckoutErrorMessage(error)
                }
                self.presentErrorDialog(error?.code, reason: errorMessage)
                return
            }
            
            print("shippingRates count: \(rates.count)")
            self.addShippingOptions(rates)
            self.tableView.reloadData()
        })
    }
    
    fileprivate func addShippingOptions(_ options : [BUYShippingRate]) {
        shippingOptions.removeAll()
        for option in options {
            let standardGround = ShippingOption()
            standardGround.name = option.title
            standardGround.price = CGFloat(option.price.doubleValue)
            standardGround.timeDetail = "East coast: 3-5 business days\nWest coast: 3-5 business days"
            standardGround.deliveryTime = "Delivery: Monday - Friday"
            standardGround.id = Int(option.shippingRateIdentifier)//Int(option.identifierValue)
            shippingOptions.append(standardGround)
            model.selectedOption = shippingOptions[0]
            selectedShippingRate = option
        }
        
        if shippingOptions.count > 0 {
            continueButton.isEnabled = true
        }
    }
    
    // MARK: - Callback methods
    func updateShippingAddress(_ model: AddressInfoModel) {
        newShippingInfo = model
        fetchShippingRates()
    }
}

extension ShippingMethodVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shippingOptions.count + 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return 107
        }
        else if indexPath.row == 1 {
            return 48
        }else {
            return 124
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShippingAddressSameAsCell", for: indexPath) as! ShippingAddressSameAsCell
            enterNewAddressButton = cell.enterNewAddressButton
            cell.enterNewAddressButton.addTarget(self, action: #selector(ShippingMethodVC.enterNewAddressPressed), for: .touchUpInside)
            cell.shippingSameAsBillingToggle.addTarget(self, action: #selector(ShippingMethodVC.shippingSameAsBillingValueChanged(_:)), for: .valueChanged)
            
            if cell.shippingSameAsBillingToggle.isOn == false {
                enterNewAddressButton?.isEnabled = true
                enterNewAddressButton?.isHidden = false
            } else{
                enterNewAddressButton?.isEnabled = false
                enterNewAddressButton?.isHidden = true
            }
            cell.selectionStyle = .none
            return cell
        }
        else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectAShippingMethodCell", for: indexPath) as! SelectAShippingMethodCell
            cell.selectionStyle = .none
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "ShippingMethodCell", for: indexPath) as! ShippingMethodCell
        cell.updateWithData(shippingOptions[indexPath.row - 2])
        
        if model.selectedOption != nil && model.selectedOption!.id == shippingOptions[indexPath.row - 2].id {
            cell.setMethodSelected(true)
        }else{
            cell.setMethodSelected(false)
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 || indexPath.row == 1 {
            return
        }
        
        selectedIndexPath = indexPath
        model.selectedOption = shippingOptions[selectedIndexPath.row - 2]
        tableView.reloadData()
    }
}
