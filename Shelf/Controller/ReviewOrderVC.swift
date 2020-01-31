//
//  ReviewOrderVC.swift
//  Shelf
//
//  Created by Nathan Konrad on 10/25/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation
import Buy
import ROKOMobi
import Firebase

let kReviewOrderVCIdentifier = "ReviewOrderVC"

class ReviewOrderVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var confirmPurchaseButtonView: UIView!
    @IBOutlet weak var confirmPurchaseButton: ShelfButton!
    
    var order : CurrentOrder!
    
    override func viewDidLoad() {
        setupNavigationBar()
        setupTableView()
        setupBottomBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Review Order"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        title = ""
    }
    
    func setupNavigationBar() {
        let attr = [NSFontAttributeName: UIFont(name: "Avenir-Black", size: 16)!,
                    NSForegroundColorAttributeName: UIColor.white,
                    NSKernAttributeName: 0.53] as [String : Any]
        navigationController?.navigationBar.titleTextAttributes = attr
        
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 18))
        backButton.setImage(UIImage(named: "backButton"), for: UIControlState())
        backButton.addTarget(self, action: #selector(ReviewOrderVC.backButtonPressed(_:)), for: .touchUpInside)
        let backButtonItem = UIBarButtonItem(customView: backButton)
        backButtonItem.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = backButtonItem
        
        let emptyButton = UIButton(frame: CGRect(x: 0, y: 0, width: 17, height: 17))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: emptyButton)
    }

    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 77, 0)
        tableView.register(UINib(nibName: kReviewOrderInfoCellIdentifier, bundle: nil), forCellReuseIdentifier: kReviewOrderInfoCellIdentifier)
        tableView.separatorColor = UIColor.clear
    }
    
    func setupBottomBar() {
        confirmPurchaseButtonView.roundAndAddDropShadow(8, shadowOpacity: 0.15, width: 0, height: 1, shadowRadius: 1)
        confirmPurchaseButton.setBackgroundColor(UIColor.init(white: 1, alpha: 0.3), forState: .highlighted)
        confirmPurchaseButton.layer.cornerRadius = 8
        confirmPurchaseButton.layer.masksToBounds = true
    }
    
    // MARK: - Helper functions
    func uploadToShopify() {
        AppDelegate.showActivity()
        BUYCheckoutManager.sharedInstance.completeCheckoutToShopifyWithToken { (checkout: BUYCheckout?, error: NSError?) in
            AppDelegate.hideActivity()
            guard error == nil, let checkout = checkout else {
                // Display ERROR Alert
                if let error = error {
                    let errorMessage = ShopifyErrorParser.sharedInstance.getCheckoutErrorMessage(error)
                    self.presentErrorDialog(error.code, reason: errorMessage)
                }
                return
            }
            
            if let orderId = checkout.order.identifier {
                AnalyticsHelper.sendCustomEvent(kFIREventEcommercePurchase)
                self.transitionToOrderConfirmationVC(orderId)
            }
        }
    }
    
    func transitionToOrderConfirmationVC(_ orderID : NSNumber) {
        let vc: OrderConfirmationVC = storyboard?.instantiateViewController(withIdentifier: kOrderConfirmationVCIdentifier) as! OrderConfirmationVC
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - IBAction
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func editShippingButtonPressed(_ sender: AnyObject) {
        let vc = storyboard?.instantiateViewController(withIdentifier: kAddressInfoVCIdentifier) as! AddressInfoVC
//        vc.isShipping = true
//        vc.updateBilling = updateShipping
        vc.model = order.creditCard
        vc.confirmShippingAddressFromReviewOrder = updateShippingAddress
        navigationController?.pushViewController(vc, animated: true)
        
//        let nc = UINavigationController(rootViewController: vc)
//        navigationController?.presentViewController(nc, animated: true, completion: nil)
    }
    
    @IBAction func editShippingMethodButtonPressed(_ sender: AnyObject) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ShippingMethodVC") as! ShippingMethodVC
//        vc.presentModal = true
//        vc.updateShippingMethod = updateShippingMethod
        vc.confirmShippingMethodFromReviewOrder = updateShippingMethod
        vc.model = order.shippingMethodInfo!
        vc.order = order
        navigationController?.pushViewController(vc, animated: true)
//        let nc = UINavigationController(rootViewController: vc)
//        navigationController?.presentViewController(nc, animated: true, completion: nil)
    }
    
    @IBAction func editPaymentButtonPressed(_ sender: AnyObject) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "PaymentVC") as! PaymentVC
//        vc.presentModal = true
//        vc.updatePaymentMethod = updatePaymentInfo
        vc.confirmPaymentFromReviewOrder = updatePaymentInfo
        vc.model = order.creditCard
        navigationController?.pushViewController(vc, animated: true)
//        let nc = UINavigationController(rootViewController: vc)
//        navigationController?.presentViewController(nc, animated: true, completion: nil)
    }
    
    @IBAction func viewItemsButtonPressed(_ sender: AnyObject) {
        let vc = storyboard?.instantiateViewController(withIdentifier: kShoppingCartVCIdentifier) as! ShoppingCartVC
        vc.updateShoppingCart = updateShoppingCart
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func confirmPurchaseButtonPressed(_ sender: AnyObject) {
        // Display Alert
        let alert = UIAlertController(title: "Confirm Purchase", message: "Are you sure to confirm purchase", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction) in
            self.uploadToShopify()
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        navigationController?.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Callback methods
    func updateShippingAddress(_ address : AddressInfoModel) {
        order.shippingInfo = address
        tableView.reloadData()
    }
    
    func updateShippingMethod(_ shippingModel : ShippingMethodModel) {
        order.shippingMethodInfo = shippingModel
        tableView.reloadData()
    }
    
    func updatePaymentInfo(_ cc : CreditCard) {
        order.creditCard = cc
        tableView.reloadData()
    }

    func updateShoppingCart() {
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ReviewOrderVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let _ = BUYCheckoutManager.sharedInstance.checkout {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 526
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kReviewOrderInfoCellIdentifier, for: indexPath) as! ReviewOrderInfoCell

        if let checkout = BUYCheckoutManager.sharedInstance.checkout {
            cell.updateWithData(checkout)
        }
        
        let paymentModel = order.creditCard
        var creditCard = "****"
        if let payment = paymentModel  {
            creditCard = String(payment.creditCardNumber.characters.suffix(4))
        }
        cell.paymentLabel.updateAttributedTextWithString("************\(creditCard)")
        
        cell.shippingAddressEditButton.addTarget(self, action: #selector(ReviewOrderVC.editShippingButtonPressed(_:)), for: .touchUpInside)
        cell.shippingMethodEditButton.addTarget(self, action: #selector(ReviewOrderVC.editShippingMethodButtonPressed(_:)), for: .touchUpInside)
        cell.paymentEditButton.addTarget(self, action: #selector(ReviewOrderVC.editPaymentButtonPressed(_:)), for: .touchUpInside)
        cell.promoCodeEditButton.addTarget(self, action: #selector(ReviewOrderVC.editPaymentButtonPressed(_:)), for: .touchUpInside)
        cell.viewItemsButton.addTarget(self, action: #selector(ReviewOrderVC.viewItemsButtonPressed(_:)), for: .touchUpInside)
        
        return cell
    }
}
