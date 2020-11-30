//
//  AddressInfoVC.swift
//  Shelf
//
//  Created by Matthew James on 10/31/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import UIKit
import PhoneNumberKit
import SwiftKeychainWrapper
import Buy
import Firebase

let kAddressInfoVCIdentifier = "AddressInfoVC"

class AddressInfoVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomButtonsView: UIView!
    @IBOutlet weak var continueButtonView: UIView!
    @IBOutlet weak var continueButton: ShelfButton!
    @IBOutlet weak var saveForLaterLabel: ShelfLabel!
    @IBOutlet weak var saveForLaterSwitch: UISwitch!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var continueButtonViewTrailingConstraint: NSLayoutConstraint!
    
    var model : CreditCard!
    var order = CurrentOrder()
    var isSaveForLater = true
    var confirmShippingAddressFromSettings: (() -> ())?
    var confirmShippingAddressFromShippingMethod: ((AddressInfoModel) -> ())?
    var confirmShippingAddressFromReviewOrder: ((AddressInfoModel) -> ())?
    var confirmAddressAddNewCard: (() -> ())?
    var confirmAddressUpdateCard: ((Int) -> ())?

    fileprivate var progressImageView : UIImageView?
    fileprivate var textField: UITextField?
    
    override func viewDidLoad() {
        print("viewDidLoad")
        super.viewDidLoad()
        
        setupNavBar()
        setupTableView()
        setupBottomBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("AddressInfoVC: viewWillDisappear")
        super.viewWillDisappear(animated)
        if let progressView = progressImageView {
            progressView.removeFromSuperview()
        }
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("AddressInfoVC: viewWillAppear")
        super.viewWillAppear(animated)
        
        // From Shipping Method
        if let _ = confirmShippingAddressFromShippingMethod {
            progressImageView = addProgressToNavBar("ProgressBarShipping")
            model = CreditCard()
            if let shipping = ShippingManager.sharedInstance.shipping {
                model.billingAddress = shipping
                tableView.reloadData()
            }
            
        }
        // From Review Order
        else if let _ = confirmShippingAddressFromReviewOrder {
            // Model is set
            progressImageView = addProgressToNavBar("ProgressBarShipping")
            
        }
        // From Settings
        else if let _ = confirmShippingAddressFromSettings {
            title = "Shipping Address"
            model = CreditCard()
            if let shipping = ShippingManager.sharedInstance.shipping {
                model.billingAddress = shipping
                tableView.reloadData()
            }
            
            continueButtonViewTrailingConstraint.constant = 17
//            view.layoutIfNeeded()
            
        }
        // From Add/Edit Payment New Card
        else if let _ = confirmAddressAddNewCard {
            title = "Cardholder Info"
            
        }
        // From Add/Edit Payment Update Card
        else if let _ = confirmAddressUpdateCard {
            title = "Cardholder Info"
            if model != nil {
                isSaveForLater = model.isDefaultCreditCard
                saveForLaterSwitch.isOn = isSaveForLater
            }
            
        }
        // Default: From Shopping Cart
        else {
            progressImageView = addProgressToNavBar("ProgressBarAddress")
            
            if model == nil {
                if let defaultCard = CreditCardManager.sharedInstance.defaultCard {
                    model = defaultCard
                } else {
                    model = CreditCard()
                }
            }
            else {
                isSaveForLater = model.isDefaultCreditCard
                saveForLaterSwitch.isOn = isSaveForLater
            }
            
        }
        
        // NOTE:
        if let textField = textField {
            textField.becomeFirstResponder()
        }
        checkIfContinueIsEnabled()
        NotificationCenter.default.addObserver(self, selector: #selector(AddressInfoVC.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AddressInfoVC.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func backPressedModal() {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    override func backPressed() {
        view.endEditing(true)
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Setup helper functions
    func setupNavBar(_ name : String = "") {
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 18))
        backButton.setImage(UIImage(named: "backButton"), for: UIControlState())
        backButton.addTarget(self, action: #selector(AddressInfoVC.backPressed), for: .touchUpInside)
        let backButtonItem = UIBarButtonItem(customView: backButton)
        backButtonItem.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = backButtonItem
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        
        let emptyButton = UIButton(frame: CGRect(x: 0, y: 0, width: 17, height: 17))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: emptyButton)
        
        // From Shipping Method
        if let _ = confirmShippingAddressFromShippingMethod {
//            progressImageView = addProgressToNavBar("ProgressBarShipping")
            
        }
        // From Review Order
        else if let _ = confirmShippingAddressFromReviewOrder {
//            progressImageView = addProgressToNavBar("ProgressBarShipping")
            
        }
        // From Settings
        if let _ = confirmShippingAddressFromSettings {
//            title = "Shipping Address"
            
        }
        // From Add/Edit Payment New Card
        else if let _ = confirmAddressAddNewCard {
//            title = "Cardholder Info"
            
        }
        // From Add/Edit Payment Update Card
        else if let _ = confirmAddressUpdateCard {
//            title = "Cardholder Info"
            
        }
        // Default: From Shopping Cart
        else {
//            progressImageView = addProgressToNavBar("ProgressBarAddress")
            
        }
    }
    
    func setupTableView() {
        print("setupTableView")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: kGenericAddressCellIdentifier, bundle: nil), forCellReuseIdentifier: kGenericAddressCellIdentifier)
        tableView.register(UINib(nibName: kGenericTwoFieldAddressCellIdentifier, bundle: nil), forCellReuseIdentifier: kGenericTwoFieldAddressCellIdentifier)
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
    }
    
    func setupBottomBar() {
        print("setupBottomBar")
        var buttonText = "CONTINUE: PAYMENT"
        
        // From Shipping Method
        if let _ = confirmShippingAddressFromShippingMethod {
            buttonText = "CONFIRM SHIPPING ADDRESS"
            
        }
        // From Review Order
        else if let _ = confirmShippingAddressFromReviewOrder {
            buttonText = "CONFIRM SHIPPING ADDRESS"
            
        }
        // From Settings
        if let _ = confirmShippingAddressFromSettings {
            buttonText = "CONFIRM SHIPPING ADDRESS"
            saveForLaterSwitch.isHidden = true
            saveForLaterLabel.isHidden = true
            
        }
        // From Add/Edit Payment New Card
        else if let _ = confirmAddressAddNewCard {
            buttonText = "COMPLETE: ADD NEW CARD"
            saveForLaterLabel.text = "MAKE CARD DEFAULT"
            
        }
        // From Add/Edit Payment Update Card
        else if let _ = confirmAddressUpdateCard {
            buttonText = "COMPLETE: UPDATE CARD"
            saveForLaterLabel.text = "MAKE CARD DEFAULT"
            
        }
        // Default: From Shopping Cart
        else {
            // Do Nothing
            
        }
        
        continueButton.updateAttributedTextWithString(buttonText, forState: UIControlState())
        continueButtonView.roundAndAddDropShadow(8, shadowOpacity: 0.15, width: 0, height: 1, shadowRadius: 1)
        continueButton.setBackgroundColor(UIColor.init(white: 1, alpha: 0.3), forState: .highlighted)
        continueButton.layer.cornerRadius = 8
        continueButton.layer.masksToBounds = true
        saveForLaterSwitch.isOn = isSaveForLater
    }
    
    // MARK: - NSNotification callback functions
    func keyboardWillShow (_ notification: Notification) {
        print("AddressInfoVC: keyboardWillShow")
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            
            UIView.animate(withDuration: duration, animations: {
                self.bottomConstraint.constant = endFrame!.size.height
                self.tableViewBottomConstraint.constant = endFrame!.size.height
                self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 76, 0)
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func keyboardWillHide (_ notification: Notification) {
        print("AddressInfoVC: keyboardWillHide")
         if let userInfo = notification.userInfo {
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            UIView.animate(withDuration: duration, animations: {
                self.bottomConstraint.constant = 0
                self.tableViewBottomConstraint.constant = 0
                self.tableView.contentInset = UIEdgeInsets.zero
                self.view.layoutIfNeeded()
                                        
            })
        }
    }
    
    // MARK: - IBAction
    @IBAction func continuePaymentTapped(_ sender: AnyObject) {
        model.isDefaultCreditCard = isSaveForLater
        
        // From Shipping Method
        if let _ = confirmShippingAddressFromShippingMethod {
            if isSaveForLater == true {
                saveShipping()
            }
            uploadUpdatedAddressToShopify()
            
        }
        // From Review Order
        else if let _ = confirmShippingAddressFromReviewOrder {
            if isSaveForLater == true {
                saveShipping()
            }
            uploadUpdatedAddressToShopify()
            
        }
        // From Settings
        else if let _ = confirmShippingAddressFromSettings {
            if isSaveForLater == true {
                saveShipping()
            }
            navigationController?.popViewController(animated: true)
            
        }
        // From Add/Edit Payment New Card
        else if let confirmAddressNewCard = confirmAddressAddNewCard {
            CreditCardManager.sharedInstance.updateAddPayment(model)
            confirmAddressNewCard()
            AnalyticsHelper.sendCustomEvent(kFIREventAddPaymentInfo)
            popBackToAddEditPaymentVC()
            
        }
        // From Add/Edit Payment Update Card
        else if let confirmAddressUpdateCard = confirmAddressUpdateCard {
            let index = CreditCardManager.sharedInstance.updateAddPayment(model)
            confirmAddressUpdateCard(index)
            AnalyticsHelper.sendCustomEvent(kFIREventAddPaymentInfo)
            popBackToAddEditPaymentVC()
            
        }
        // Default: From Shopping Cart
        else {
            order.creditCard = model
            BUYCheckoutManager.sharedInstance.updateCheckoutWithBillingAddress(model.billingAddress)
            BUYCheckoutManager.sharedInstance.updateCheckoutWithShippingAddress(model.billingAddress)
            // Transition to PaymentVC
            let vc = storyboard?.instantiateViewController(withIdentifier: kPaymentVCIdentifier) as! PaymentVC
            vc.order = order
            vc.model = model
            vc.isSaveInfoForLater = isSaveForLater
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
            view.endEditing(true)
            navigationController?.pushViewController(vc, animated: true)
            
        }
    }

    
    @IBAction func saveInfoForLaterSwitchValueChanged(_ sender: AnyObject) {
        isSaveForLater = !isSaveForLater
    }
    
    // MARK: - Helper functions
    func nameChanged(_ textField : UITextField) {
        if let text = textField.text {
            model.billingAddress.name = text
        }
        checkIfContinueIsEnabled()
    }
    
    func addressChanged(_ textField : UITextField) {
        if let text = textField.text {
            model.billingAddress.address = text
        }
        checkIfContinueIsEnabled()
    }
    
    func aptSteChanged(_ textField : UITextField) {
        if let text = textField.text {
            model.billingAddress.aptSte = text
        }
        checkIfContinueIsEnabled()
    }
    
    func coChanged(_ textField : UITextField) {
        if let text = textField.text {
            model.billingAddress.co = text
        }
      
        checkIfContinueIsEnabled()
    }
    
    func cityChanged(_ textField : UITextField) {
        if let text = textField.text {
            model.billingAddress.city = text
        }
        checkIfContinueIsEnabled()
    }
    
    func stateChanged(_ textField : UITextField) {
        if let text = textField.text {
            model.billingAddress.state = text
        }
        checkIfContinueIsEnabled()
    }
    
    func zipChanged(_ textField : UITextField) {
        if let text = textField.text {
            model.billingAddress.zip = text
        }
        checkIfContinueIsEnabled()
    }
    
    func phoneChanged(_ textField : UITextField) {
        if let text = textField.text {
            let formatted = PartialFormatter().formatPartial(text)
            textField.text = formatted
            model.billingAddress.phone = formatted
        }
        checkIfContinueIsEnabled()
    }
    
    func checkIfContinueIsEnabled() {
        if model.billingAddress.phone.isEmpty == false && model.billingAddress.phone.characters.count > 13 && model.billingAddress.zip.isEmpty == false && model.billingAddress.zip.characters.count >= 5 && model.billingAddress.state.isEmpty == false && model.billingAddress.city.isEmpty == false && model.billingAddress.address.isEmpty == false && model.billingAddress.name.verifyFullName() == true {
            continueButton.isEnabled = true
            continueButtonView.alpha = 1
        } else {
            continueButton.isEnabled = false
            continueButtonView.alpha = 0.5
        }
    }
    
    fileprivate func saveShipping() {
        ShippingManager.sharedInstance.shipping = model.billingAddress
        ShippingManager.sharedInstance.secureSave()
    }
    
    fileprivate func uploadUpdatedAddressToShopify() {
        BUYCheckoutManager.sharedInstance.updateCheckoutWithShippingAddress(model.billingAddress)
        AppDelegate.showActivity()
        BUYCheckoutManager.sharedInstance.updateCheckoutToShopify({ (checkout: BUYCheckout?, error: NSError?) in
            guard error == nil, let checkout = checkout else {
                // Display ERROR Alert
                var errorMessage = "Update shipping address info failed"
                if let error = error {
                    errorMessage = ShopifyErrorParser.sharedInstance.getCheckoutErrorMessage(error)
                }
                self.presentErrorDialog(error?.code, reason: errorMessage)
                return
            }

            // From Shipping Method
            if let confirmShippingAddressFromShippingMethod = self.confirmShippingAddressFromShippingMethod {
                AppDelegate.hideActivity()
                confirmShippingAddressFromShippingMethod(self.model.billingAddress)
                self.navigationController?.popViewController(animated: true)
            }
            // From Review Order
            else if let confirmShippingAddressFromReviewOrder = self.confirmShippingAddressFromReviewOrder {
                // NOTE: Temporary fix
                if let shippingRates = BUYCheckoutManager.sharedInstance.shippingRates, shippingRates.count > 0 {
                    let shippingRate = shippingRates[0]
                    checkout.shippingRate = shippingRate
                }

                BUYCheckoutManager.sharedInstance.updateCheckoutToShopify({ (checkout: BUYCheckout?, error: NSError?) in
                    AppDelegate.hideActivity()
                    guard error == nil, let _ = checkout else {
                        // Display ERROR Alert
                        var errorMessage = "Update shipping address info failed"
                        if let error = error {
                            errorMessage = ShopifyErrorParser.sharedInstance.getCheckoutErrorMessage(error)
                        }
                        self.presentErrorDialog(error?.code, reason: errorMessage)
                        return
                    }

                    confirmShippingAddressFromReviewOrder(self.model.billingAddress)
                    self.navigationController?.popViewController(animated: true)
                })
            }
        })
    }
    
    fileprivate func popBackToAddEditPaymentVC() {
        if let viewControllers = navigationController?.viewControllers {
            for vc in viewControllers {
                if let vc = vc as? AddEditPaymentVC {
                    navigationController?.popToViewController(vc, animated: true)
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource, UITableDelegate
extension AddressInfoVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: kGenericAddressCellIdentifier) as! GenericAddressCell
                if model != nil {
                    cell.userContent.text = model.billingAddress.name
                }
                cell.userContent.becomeFirstResponder()
                textField = cell.userContent
                cell.setupCellType(.name)
                cell.userContent.addTarget(self, action: #selector(AddressInfoVC.nameChanged(_:)), for: .editingChanged)
                return cell
            
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: kGenericAddressCellIdentifier) as! GenericAddressCell
                if model != nil {
                    cell.userContent.text = model.billingAddress.address
                }
                cell.setupCellType(.address)
                cell.userContent.addTarget(self, action: #selector(AddressInfoVC.addressChanged(_:)), for: .editingChanged)
                return cell
            
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: kGenericTwoFieldAddressCellIdentifier) as! GenericTwoFieldAddressCell
                if model != nil {
                    cell.firstUserField.text = model.billingAddress.aptSte
                    cell.secondUserField.text = model.billingAddress.co
                }
                cell.setupCellType(.aptSte)
                cell.firstUserField.addTarget(self, action: #selector(AddressInfoVC.aptSteChanged(_:)), for: .editingChanged)
                cell.secondUserField.addTarget(self, action: #selector(AddressInfoVC.coChanged(_:)), for: .editingChanged)
                return cell
            
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: kGenericAddressCellIdentifier) as! GenericAddressCell
                if model != nil {
                    cell.userContent.text = model.billingAddress.city
                }
                cell.setupCellType(.city)
                cell.userContent.addTarget(self, action: #selector(AddressInfoVC.cityChanged(_:)), for: .editingChanged)
                return cell
            
            case 4:
                let cell = tableView.dequeueReusableCell(withIdentifier: kGenericTwoFieldAddressCellIdentifier) as! GenericTwoFieldAddressCell
                if model != nil {
                    cell.firstUserField.text = model.billingAddress.state
                    cell.secondUserField.text = model.billingAddress.zip
                }
                cell.setupCellType(.stateZip)
                cell.firstUserField.addTarget(self, action: #selector(AddressInfoVC.stateChanged(_:)), for: .editingChanged)
                cell.secondUserField.addTarget(self, action: #selector(AddressInfoVC.zipChanged(_:)), for: .editingChanged)
                return cell
            
            case 5:
                let cell = tableView.dequeueReusableCell(withIdentifier: kGenericAddressCellIdentifier) as! GenericAddressCell
                if model != nil {
                    cell.userContent.text = model.billingAddress.phone
                }
                cell.setupCellType(.phone)
                cell.separatorView.isHidden = true
                cell.userContent.addTarget(self, action: #selector(AddressInfoVC.phoneChanged(_:)), for: .editingChanged)
                return cell
            
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: kGenericTwoFieldAddressCellIdentifier) as! GenericTwoFieldAddressCell
                cell.setupCellType(.stateZip)
                return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 47
    }
}
