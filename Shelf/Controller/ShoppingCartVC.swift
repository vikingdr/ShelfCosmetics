//
//  ShoppingCartVC.swift
//  Shelf
//
//  Created by Matthew James on 10/25/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import UIKit
import PassKit
import Buy
import DZNEmptyDataSet
import Firebase

let kShoppingCartVCIdentifier = "ShoppingCartVC"

class ShoppingCartVC: BaseVC {

    let kMerchantId = "merchant.shelfcosmetics.Shelf"
    let kSupportedNetworks = [PKPaymentNetwork.visa, PKPaymentNetwork.masterCard, PKPaymentNetwork.amex]
    var dismissVC : (() -> ())?
    var updateShoppingCart : (() -> ())?
    var isFromSettings: Bool = false
    
//    var checkout: BUYCheckout!
    var shop: BUYShop!
    var applePayHelper: BUYApplePayAuthorizationDelegate!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewWithButtons: UIView!
    @IBOutlet weak var viewWithButtonsBackgroundView: UIView!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var subtotalText: ShelfLabel!
    @IBOutlet weak var shippingTaxesDisclaimerLabel: ShelfLabel!
    @IBOutlet weak var checkoutButtonView: UIView!
    @IBOutlet weak var checkoutButton: ShelfButton!
    @IBOutlet weak var applePayButtonView: UIView!
    @IBOutlet weak var applePayButton: ShelfButton!
    
    @IBOutlet weak var checkoutButtonTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var applePayButtonEqualWidthConstraint: NSLayoutConstraint!
    
   fileprivate var authorizedPayment = false
    
    override func viewDidLoad() {
        setupNavigationBar()
        setupTableView()
        setupBottomBar()
        
        tableView.reloadData()
        updateSubtotal()
        
        // We are presenting from Review Order
        if let _ = updateShoppingCart {
//            applePayButton.hidden = true
//            buttonsView.removeConstraint(applePayButtonEqualWidthConstraint)
//            buttonsView.removeConstraint(checkoutButtonTrailingConstraint)
//            
//            view.addConstraint(NSLayoutConstraint(item: checkoutButton, attribute: .Trailing, relatedBy: .Equal, toItem: buttonsView, attribute: .Trailing, multiplier: 1, constant: 0))
//            view.layoutIfNeeded()
//            
//            checkoutButton.setTitle("Update Cart", forState: .Normal)
            viewWithButtons.isHidden = true
        } else {
            viewWithButtons.isHidden = false
        }

//        // TODO: For future?
//        ShopifyAPI().getShippingZones { (responseObject) in
//            guard let responseObject = responseObject as? [String: AnyObject],
//            let sZones = responseObject[kShopifyShippingZones] as? [[String: AnyObject]] else {
//                    return
//            }
//            
//            var shippingZones = [ShopifyShippingZone]()
//            for object in sZones {
//                if let shippingZone = ShopifyShippingZone(JSON: object) {
//                    shippingZones.append(shippingZone)
//                }
//            }
//            
//            print("getShippingZones API")
//            self.displayData(shippingZones)
//        }
    }
    
//    private func displayData(shippingZones: [ShopifyShippingZone]) {
//        print("shippingZones count: \(shippingZones.count)")
//        if shippingZones.count > 0 {
//            let shippingZone = shippingZones[0]
//            if let weightBasedShippingRates = shippingZone.weightBasedShippingRates {
//                if weightBasedShippingRates.count > 0 {
//                    let shippingRate = weightBasedShippingRates[0]
//                    if let shippingRateName = shippingRate.name {
//                        print("Shipping Method: \(shippingRateName)")
//                    }
//                    if let shippingRatePrice = shippingRate.price {
//                        print("Price: $\(shippingRatePrice)")
//                    }
//                }
//            }
//            
//            if let countries = shippingZone.countries {
//                if countries.count > 0 {
//                    let country = countries[0]
//                    if let countryName = country.name, let countryTaxName = country.taxName {
//                        print("\(countryName): \(countryTaxName)")
//                    }
//                    
//                    if let provinces = country.provinces {
//                        for province in provinces {
//                            if let provinceName = province.name, let taxName = province.taxName, let provinceTax = province.tax {
//                                if provinceName == "California" {
//                                    print("\(provinceName) \(taxName): \(provinceTax)")
//                                }
//                            }
//                            
//                            if let provinceCode = province.code, let taxName = province.taxName, let provinceTax = province.tax {
//                                if provinceCode == "CA" {
//                                    print("\(provinceCode) \(taxName): \(provinceTax)")
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
    
    // MARK: - Setup helper functions
    override func setupNavigationBar() {
        super.setupNavigationBar()
        title = "Shopping Cart"
        
        // From Review Order
        if let _ = updateShoppingCart {
            title = "View Items"
        }
        // From Product Info
        else if let _ = dismissVC {
            let emptyButton = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 18))
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: emptyButton)
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "closeButton"), style: .plain, target: self, action: #selector(ShoppingCartVC.closePressed))
            navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        }
        // From Settings
        else {
            // DO Nothing?
        }
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: kShoppingCartCellIdentifier, bundle: nil), forCellReuseIdentifier: kShoppingCartCellIdentifier)
        tableView.estimatedRowHeight = 450
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 127, 0)
    }
    
    func setupBottomBar() {
        checkoutButtonView.roundAndAddDropShadow(5, shadowOpacity: 0.15, width: 0, height: 1, shadowRadius: 1)
        checkoutButton.setBackgroundColor(UIColor.init(white: 1, alpha: 0.3), forState: .highlighted)
        checkoutButton.layer.cornerRadius = 5
        checkoutButton.layer.masksToBounds = true
        
        applePayButton.isHidden = !PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: kSupportedNetworks)
        if applePayButton.isHidden == true {
            buttonsView.removeConstraint(applePayButtonEqualWidthConstraint)
            buttonsView.removeConstraint(checkoutButtonTrailingConstraint)
            
            view.addConstraint(NSLayoutConstraint(item: checkoutButtonView, attribute: .trailing, relatedBy: .equal, toItem: buttonsView, attribute: .trailing, multiplier: 1, constant: 0))
            view.layoutIfNeeded()
        } else {
            applePayButtonView.roundAndAddDropShadow(5, shadowOpacity: 0.15, width: 0, height: 1, shadowRadius: 1)
            applePayButton.setBackgroundColor(UIColor.black.withAlphaComponent(0.3), forState: .highlighted)
            applePayButton.layer.cornerRadius = 5
            applePayButton.layer.masksToBounds = true
            
            // Prefetch the shop object for Apple Pay
            BUYClient.sharedClient.getShop({ (shop: BUYShop?, error: NSError?) in
                guard error == nil, let shop = shop else {
                    return
                }
                
                self.shop = shop
            } as! BUYDataShopBlock)
        }
    }
    
    // MARK: - IBAction
    @IBAction func checkoutPressed(_ sender: AnyObject) {
        BUYCart.sharedCart.setLineItems()
        createCheckout(false)
    }
    
    @IBAction func applePayPressed(_ sender: AnyObject) {
        // Create BUYCheckout object first
        BUYCart.sharedCart.setLineItems()
        createCheckout(true)
    }
    
    override func backPressed() {
        // From Review Order
        if let updateShoppingCart = updateShoppingCart {
            // Check if count is 0, dismiss back to Product Info
            if BUYCart.sharedCart.mutableLineItemsArray().count == 0 {
                dismiss(animated: true, completion: nil)
                BUYCheckoutManager.sharedInstance.clearCheckout()
                AnalyticsHelper.sendCustomEvent(kFIREventCartAbandonment)
            }
            // Pop back to Review Order
            else {
                AppDelegate.showActivity()
                BUYCheckoutManager.sharedInstance.updateCheckoutWithCart({ (checkout: BUYCheckout?, error: NSError?) in
                    AppDelegate.hideActivity()
                    guard error == nil, let _ = checkout else {
                        var errorMessage = "Cart update failed"
                        if let error = error {
                            print("updateCheckoutWithCart error: \(error)")
                            errorMessage = ShopifyErrorParser.sharedInstance.getCheckoutErrorMessage(error)
                        }
                        self.presentErrorDialog(error?.code, reason: errorMessage)
                        return
                    }
                    
                    updateShoppingCart()
                    self.navigationController?.popViewController(animated: true)
                })
            }
        }
        // From Settings, pop back to Settings
        else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func closePressed() {
        dismiss(animated: true, completion: nil)
        BUYCheckoutManager.sharedInstance.clearCheckout()
        AnalyticsHelper.sendCustomEvent(kFIREventCartAbandonment)
    }
    
    // MARK: - Helper functions
    func updateSubtotal() {
        var subtotal: NSDecimalNumber = NSDecimalNumber.zero
        for lineItem in BUYCart.sharedCart.mutableLineItemsArray() {
            subtotal = subtotal.adding(lineItem.linePrice)
        }
        
        if let subtotalString = subtotal.currencyFormat {
            subtotalText.updateAttributedTextWithString("SUBTOTAL: " + subtotalString)
        }
        
        if subtotal == NSDecimalNumber.zero {
            checkoutButton.alpha = 0.61
            applePayButton.alpha = 0.5
            subtotalText.alpha = 0.5
            shippingTaxesDisclaimerLabel.alpha = 0.5
            checkoutButton.isUserInteractionEnabled = false
            applePayButton.isUserInteractionEnabled = false
        } else {
            checkoutButton.alpha = 1
            applePayButton.alpha = 1
            subtotalText.alpha = 1
            shippingTaxesDisclaimerLabel.alpha = 0.7
            checkoutButton.isUserInteractionEnabled = true
            applePayButton.isUserInteractionEnabled = true
        }
    }
    
    func createCheckout(_ isApplePay: Bool) {
        // Has existing BUYCheckout
        if let checkout = BUYCheckoutManager.sharedInstance.checkout, let _ = checkout.token {
            // Update Checkout
            BUYCheckoutManager.sharedInstance.updateCheckoutWithCart({ (checkout: BUYCheckout?, error: NSError?) in
                guard error == nil, let _ = checkout else {
                    AppDelegate.hideActivity()
                    // Display ERROR Alert
                    let title = "We are sorry!"
                    var message = "Checkout Warning"
                    if let error = error {
                        let (index, errorCode) = ShopifyErrorParser.sharedInstance.getCheckoutErrorCode(error)
                        if errorCode == kShopifyErrorCodeNotEnoughInStock {
                            message = "The item \(BUYCart.sharedCart.mutableLineItemsArray()[index].variant.product.title) is currently out of stock. Please check back again soon."
                            self.presentWarningDialog(title: title, message: message)
                        }
                        else {
                            let errorMessage = ShopifyErrorParser.sharedInstance.getCheckoutErrorMessage(error)
                            self.presentErrorDialog(error.code, reason: errorMessage)
                        }
                    }
                    return
                }
                
                // Check if it's Apple Pay
                if isApplePay {
                    self.presentApplePay()
                }
                // else
                else {
                    AppDelegate.hideActivity()
                    // Transition to AddressInfoVC
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: kAddressInfoVCIdentifier) as! AddressInfoVC
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            })
        }
        // New Checkout
        else {
            // Create checkout
            AppDelegate.showActivity()
            BUYCheckoutManager.sharedInstance.createCheckout() { (checkout: BUYCheckout?, error: NSError?) in
                guard error == nil, let _ = checkout else {
//                    print("createCheckout error: \(error)")
                    // Display ERROR Alert
                    AppDelegate.hideActivity()
                    let title = "We are sorry!"
                    var message = "Checkout Warning"
                    if let error = error {
                        let (index, errorCode) = ShopifyErrorParser.sharedInstance.getCheckoutErrorCode(error)
                        if errorCode == kShopifyErrorCodeNotEnoughInStock {
                            message = "The item \(BUYCart.sharedCart.mutableLineItemsArray()[index].variant.product.title) is currently out of stock. Please check back again soon."
                            self.presentWarningDialog(title: title, message: message)
                        }
                        else {
                            let errorMessage = ShopifyErrorParser.sharedInstance.getCheckoutErrorMessage(error)
                            self.presentErrorDialog(error.code, reason: errorMessage)
                        }
                    }
                    return
                }
                
                AnalyticsHelper.sendCustomEvent(kFIREventBeginCheckout)
                // Check if it's Apple Pay
                if isApplePay {
                    self.presentApplePay()
                }
                // else
                else {
                    AppDelegate.hideActivity()
                    // Transition to AddressInfoVC
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: kAddressInfoVCIdentifier) as! AddressInfoVC
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    func presentApplePay() {
        AppDelegate.hideActivity()
    
        if let checkout = BUYCheckoutManager.sharedInstance.checkout, BUYCart.sharedCart.lineItemsArray().count > 0 {
            print("checkout total price: \(checkout.totalPrice)")
            self.applePayHelper = BUYApplePayAuthorizationDelegate(client: BUYClient.sharedClient, checkout: checkout, shopName: self.shop.name)
            
            let request = createPaymentRequest(checkout)
            let applePayController = PKPaymentAuthorizationViewController(paymentRequest: request)
            applePayController.delegate = self
            authorizedPayment = false
            
//            var canMakePayments = PKPaymentAuthorizationViewController.canMakePayments() && PKPaymentAuthorizationViewController.canMakePaymentsUsingNetworks(kSupportedNetworks)
//            if #available(iOS 9.0, *) {
//                canMakePayments = canMakePayments && PKPaymentAuthorizationViewController.canMakePaymentsUsingNetworks(kSupportedNetworks, capabilities: .Capability3DS)
//            }
//            
//            if applePayController != nil && canMakePayments {
            AnalyticsHelper.sendCustomEvent(kFIREventInitiatePurchase)
                present(applePayController, animated: true, completion: nil)
//            }
        }
    }
    
    // MARK: -
    func shoppingCartItemUpdated(_ row: Int?, delete: Bool = false) {
        if let row = row {
            // From cell remove button pressed
            if delete == true {
                let variant = BUYCart.sharedCart.mutableLineItemsArray()[row].variant
                BUYCart.sharedCart.removeVariantFromExisiting(variant!)
                
                tableView.beginUpdates()
                tableView.deleteRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
                tableView.endUpdates()
                tableView.reloadData()
            }
            // From Product Info
            else {
                tableView.beginUpdates()
                tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
                tableView.endUpdates()
            }
        }
        updateSubtotal()
    }
    
    func dismissShoppingCart() {
        if let dismissVC = dismissVC {
            dismissVC()
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension ShoppingCartVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BUYCart.sharedCart.mutableLineItemsArray().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kShoppingCartCellIdentifier) as! ShoppingCartCell
        cell.updateWithData(BUYCart.sharedCart.mutableLineItemsArray()[indexPath.row])
        cell.minusButton.tag = indexPath.row
        cell.plusButton.tag = indexPath.row
        cell.removeButton.tag = indexPath.row
        cell.shoppingCartItemUpdated = shoppingCartItemUpdated
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: kProductInfoVCIdentifier) as! ProductInfoVC
        vc.index = indexPath.row
        vc.updateCartAtIndex = shoppingCartItemUpdated
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - PKPaymentAuthorizationViewControllerDelegate
extension ShoppingCartVC: PKPaymentAuthorizationViewControllerDelegate {
    func createPaymentRequest(_ checkout: BUYCheckout) -> PKPaymentRequest {
        let request = PKPaymentRequest()
        request.merchantIdentifier = kMerchantId
        request.supportedNetworks = kSupportedNetworks
        request.requiredBillingAddressFields = .postalAddress
        if #available(iOS 8.3, *) {
            request.requiredShippingAddressFields = [.name, .postalAddress]
        } else {
            request.requiredShippingAddressFields = .all
        }
        
        request.merchantCapabilities = PKMerchantCapability.capability3DS
        request.countryCode = "US"
        request.currencyCode = "USD"
        request.paymentSummaryItems = checkout.buy_summaryItems(withShopName: shop.name)
//        request.shippingMethods = createShippingMethods()
        
        return request
    }
    
//    func createShippingMethods() -> [PKShippingMethod] {
//        let groundShipping = PKShippingMethod(label: "Standard Ground", amount: 5.95)
//        groundShipping.identifier = "Standard Ground"
//        groundShipping.detail = "1-4 business days (East coast) \n1-6 business days (West coast)\nDelivery: Monday - Friday"
//        let uspsGround = PKShippingMethod(label: "USPS Ground", amount: 5.95)
//        uspsGround.identifier = "USPS Ground"
//        uspsGround.detail = "3-8 business days\nDelivery: Monday - Friday"
//        return [groundShipping, uspsGround]
//    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: (@escaping (PKPaymentAuthorizationStatus) -> Void)) {
        print("didAuthorizePayment()")
        applePayHelper.paymentAuthorizationViewController(controller, didAuthorizePayment: payment, completion: completion)
        BUYCheckoutManager.sharedInstance.updateCheckout(applePayHelper.checkout)
        authorizedPayment = true
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        print("paymentAuthorizationViewControllerDidFinish")
        controller.dismiss(animated: true, completion: nil)
        applePayHelper.paymentAuthorizationViewControllerDidFinish(controller)
        
        if authorizedPayment {
            BUYCheckoutManager.sharedInstance.getCompletedCheckout { (error: NSError?, success: Bool) in
                guard error == nil && success == true,
                    let checkout = BUYCheckoutManager.sharedInstance.checkout,
                    let order = checkout.order else {
                    // TODO: Display ERROR Alert
                    return
                }
                
                print("order: \(order)")
                let vc = self.storyboard?.instantiateViewController(withIdentifier: kOrderConfirmationVCIdentifier) as! OrderConfirmationVC
                vc.dismissShoppingCart = self.dismissShoppingCart
                AnalyticsHelper.sendCustomEvent(kFIREventEcommercePurchase)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didSelectShippingAddress address: ABRecord, completion: @escaping (PKPaymentAuthorizationStatus, [PKShippingMethod], [PKPaymentSummaryItem]) -> Void) {
        applePayHelper.paymentAuthorizationViewController(controller, didSelectShippingAddress: address, completion: completion)
    }
    
    @available(iOS 9.0, *)
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didSelectShippingContact contact: PKContact, completion: @escaping (PKPaymentAuthorizationStatus, [PKShippingMethod], [PKPaymentSummaryItem]) -> Void) {
        applePayHelper.paymentAuthorizationViewController(controller, didSelectShippingContact: contact, completion: completion)
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didSelect shippingMethod: PKShippingMethod, completion: @escaping (PKPaymentAuthorizationStatus, [PKPaymentSummaryItem]) -> Void) {
        applePayHelper.paymentAuthorizationViewController(controller, didSelect: shippingMethod, completion: completion)
    }
}

// MARK: - DZNEmptyDataSetSource, DZNEmptyDataSetDelegate
extension ShoppingCartVC: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func customView(forEmptyDataSet scrollView: UIScrollView!) -> UIView! {
        let background = Bundle.main.loadNibNamed("ShoppingCartEmptyBackground", owner: self, options: nil)?.first as! UIView
        return background
        
    }
}
