//
//  PaymentVC.swift
//  Shelf
//
//  Created by Matthew James on 11/1/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import UIKit
import Buy
import ROKOMobi
import Firebase

let kPaymentVCIdentifier = "PaymentVC"

class PaymentVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var continueButtonView: UIView!
    @IBOutlet weak var continueButton: ShelfButton!
    @IBOutlet weak var saveForLater: ShelfLabel!
    @IBOutlet weak var isSaveInfoButton: UISwitch!
    
    @IBOutlet weak var bottomViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomTableViewConstraint: NSLayoutConstraint!
    
    var isSaveInfoForLater = true
    var model : CreditCard!
    let kPaymentInfo = "paymentInfo"
    var order : CurrentOrder!
    var presentModal = false
    var confirmPaymentFromReviewOrder: ((CreditCard) -> ())?
    var confirmAddressAddNewCard: (() -> ())?
    var confirmAddressUpdateCard: ((Int) -> ())?
    var progressImageView : UIImageView?
    let kPromoTag = 1

    fileprivate var textField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if model == nil {
            if let defaultCard = CreditCardManager.sharedInstance.defaultCard {
                model = defaultCard
            }
        }
        else {
            isSaveInfoButton.isOn = model.isDefaultCreditCard
            isSaveInfoForLater = model.isDefaultCreditCard
        }
        
        setupTableView()
        setupBottomBar()
        
        checkIfContinueIsEnabled()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("PaymentVC: viewWillDisappear")
        super.viewWillDisappear(animated)
        if let imgView = progressImageView {
            imgView.removeFromSuperview()
        }
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isSaveInfoButton.isOn = isSaveInfoForLater
        
        setupNavBarModal("")
        if presentModal == false {
            setupNavBarModal("")
            setupNavBar()
        }
        
        // Add New Card
        if let _ = confirmAddressAddNewCard {
            setupNavBarModal("Card Details")
            setupNavBar()
            saveForLater.text = "MAKE CARD DEFAULT"
            continueButton.updateAttributedTextWithString("CONTINUE: ADDRESS", forState: UIControlState())
            
        }
        // Update Card
        else if let _ = confirmAddressUpdateCard {
            setupNavBarModal("Card Details")
            setupNavBar()
            saveForLater.text = "MAKE CARD DEFAULT"
            continueButton.updateAttributedTextWithString("CONTINUE: ADDRESS", forState: UIControlState())
            
        }
        else {
            progressImageView = addProgressToNavBar("ProgressBarPayment")
            if let _ = confirmPaymentFromReviewOrder {
                continueButton.updateAttributedTextWithString("CONFIRM PAYMENT", forState: UIControlState())
            }
            // Default: Checkout Payment
            else {
            
            }
            
        }
        
        if let textField = textField {
            textField.becomeFirstResponder()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(PaymentVC.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PaymentVC.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func backPressedModal() {
        dismiss(animated: true, completion: nil)
    }
    
    override func backPressed() {
        view.endEditing(true)
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Setup helper functions
    func setupNavBar() {
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 18))
        backButton.setImage(UIImage(named: "backButton"), for: UIControlState())
        backButton.addTarget(self, action: #selector(PaymentVC.backPressed), for: .touchUpInside)
        let backButtonItem = UIBarButtonItem(customView: backButton)
        backButtonItem.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = backButtonItem
        
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        
        let emptyButton = UIButton(frame: CGRect(x: 0, y: 0, width: 17, height: 17))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: emptyButton)
    }
    
    func setupTableView(){
        tableView.register(UINib(nibName: kPromoCodeCellIdentifier, bundle: nil), forCellReuseIdentifier: kPromoCodeCellIdentifier)
        tableView.register(UINib(nibName: kCreditCardsAcceptedCellIdentifier, bundle: nil), forCellReuseIdentifier: kCreditCardsAcceptedCellIdentifier)
        tableView.register(UINib(nibName: kGenericAddressCellIdentifier, bundle: nil), forCellReuseIdentifier: kGenericAddressCellIdentifier)
        tableView.register(UINib(nibName: kGenericTwoFieldAddressCellIdentifier, bundle: nil), forCellReuseIdentifier: kGenericTwoFieldAddressCellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
    }
    
    func setupBottomBar() {
        continueButtonView.roundAndAddDropShadow(8, shadowOpacity: 0.15, width: 0, height: 1, shadowRadius: 1)
        continueButton.setBackgroundColor(UIColor.init(white: 1, alpha: 0.3), forState: .highlighted)
        continueButton.layer.cornerRadius = 8
        continueButton.layer.masksToBounds = true
    }
    
    // MARK: - NSNotification callbacks
    func keyboardWillShow (_ notification: Notification) {
        print("PaymentVC: keyboardWillShow")
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            
            bottomViewConstraint.constant = endFrame!.size.height
            bottomTableViewConstraint.constant = endFrame!.size.height
            
            tableView.contentInset = UIEdgeInsetsMake(0, 0, 76, 0)
            UIView.animate(withDuration: duration,
                                       animations: {
                                        self.view.layoutIfNeeded()
            })
        }
    }
    
    func keyboardWillHide (_ notification: Notification) {
        print("PaymentVC: keyboardWillHide")
        bottomViewConstraint.constant = 0
        bottomTableViewConstraint.constant = 0
        if let userInfo = notification.userInfo {
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            UIView.animate(withDuration: duration,
                                       animations: {
                                        self.view.layoutIfNeeded()
            })
        }
    }
    
    // MARK: - IBAction
    @IBAction func saveInfoForLaterSwitched(_ sender: AnyObject) {
        isSaveInfoForLater = !isSaveInfoForLater
        model.isDefaultCreditCard = isSaveInfoForLater
    }
    
    @IBAction func continueShippingMethodPressed(_ sender: AnyObject) {
        if validateCvcExpiration() == false {
            return
        }
        
        // Has Checkout
        if let _ = BUYCheckoutManager.sharedInstance.checkout {
            AnalyticsHelper.sendCustomEvent(kFIREventAddPaymentInfo)
            AppDelegate.showActivity()
            BUYCheckoutManager.sharedInstance.updateCheckoutWithCreditCard(model) { (error: NSError?, success: Bool) in
                guard error == nil && success else {
                    AppDelegate.hideActivity()
                    // Display ERROR Alert
                    var errorMessage = "Credit Card invalid"
                    if let error = error {
                        print("updateCheckoutWithCreditCard error: \(error)")
                        errorMessage = ShopifyErrorParser.sharedInstance.getCheckoutErrorMessage(error)
                    }
                    self.presentErrorDialog(error?.code, reason: errorMessage)
                    return
                }
                
                self.validatePromoCode()
            }
        }
        // Editing
        else {
            transitionViewController()
        }
    }
    
    // MARK: -
    func validateCvcExpiration() -> Bool{
        let f = DateFormatter()
        f.dateFormat = "MM/yyyy"
        let date = f.date(from: model.expires)
        var isValidDate = false
        
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        var components = (calendar as NSCalendar).components([.month, .day, .year], from: Date())
        
        components.day = 1
        components.hour = 0
        
        if let currDate = calendar.date(from: components) {
            
            if  date?.compare(currDate) == .orderedDescending || date?.compare(currDate) == .orderedSame {
                print("date is later than curr date")
                print(model.expires)
                isValidDate = true
            }
            else if date?.compare(currDate) == .orderedAscending {
                print("date is earlier than curr date ")
                print(model.expires)
                isValidDate = false
            }
            
            if isValidDate == false {
                presentErrorDialog(-1, reason: "with the Credit Card expiration date")
                return false
            }
            
        }
        
        var isValidCvc = false
        let cvcCount = model.cvc.characters.count
        if cvcCount == 3 || cvcCount == 4 {
            isValidCvc = true
        }else{
            isValidCvc = false
        }
        
        if isValidCvc == false {
            presentErrorDialog(-2, reason: "Credit card cvc code is invalid")
            return false
        }
        return isValidDate == true && isValidCvc == true
    }
    
    fileprivate func validatePromoCode() {
        // Check if PROMO code is enter and is valid
        if model.promoCode.isEmpty == false {
            // Check with ROKOMobi
            let promo = ROKOPromo()
        
            promo.loadPromoDiscount(withPromoCode: model.promoCode, completionBlock: { (discountItem: ROKOPromoDiscountItem?, error: NSError?) in
                let num = discountItem?.value
                
                promo.markCode(asUsed: self.model.promoCode, valueOfPurchase: num, valueOfDiscount: num, deliveryType: .event, completionBlock: { (error) in
                })
            } as! ROKOPromoDiscountCompletionBlock)
            
            // Add To Shopify
            BUYCheckoutManager.sharedInstance.updateCheckoutWithDiscount(model.promoCode, completion: { (checkout: BUYCheckout?, error: NSError?) in
                AppDelegate.hideActivity()
                guard error == nil, let _ = checkout else {
                    // Display ERROR Alert
                    var errorMessage = "Promo code invalid"
                    if let error = error {
                        print("updateCheckoutWithDiscount error: \(error)")
                        errorMessage = ShopifyErrorParser.sharedInstance.getCheckoutErrorMessage(error)
                    }
                    self.presentErrorDialog(error?.code, reason: errorMessage)
                    return
                }
                self.transitionViewController()
            })
        }
        else {
            // Check if user has a promo code
            if let checkout = BUYCheckoutManager.sharedInstance.checkout {
                // Check if discount exists and code exists
                if let discount = checkout.discount, let code = discount.code {
                    // Check if code is not empty previously, user have removed code, need to update
                    if code.isEmpty == false {
                        BUYCheckoutManager.sharedInstance.updateCheckoutWithDiscount("", completion: { (checkout: BUYCheckout?, error: NSError?) in
                            // checkout.discount = nil
                            // BUYCheckoutManager.sharedInstance.updateCheckoutToShopify({ (checkout: BUYCheckout?, error: NSError?) in
                            AppDelegate.hideActivity()
                            guard error == nil, let _ = checkout else {
                                var errorMessage = "Promo code invalid"
                                if let error = error {
                                    print("removePromoCode error: \(error)")
                                    errorMessage = ShopifyErrorParser.sharedInstance.getCheckoutErrorMessage(error)
                                }
                                self.presentErrorDialog(error?.code, reason: errorMessage)
                                return
                            }
                            
                            self.transitionViewController()
                        })
                    }
                }
                else {
                    // Save address
                    BUYCheckoutManager.sharedInstance.updateCheckoutToShopify({ (checkout: BUYCheckout?, error: NSError?) in
                        AppDelegate.hideActivity()
                        guard error == nil, let _ = checkout else {
                            var errorMessage = "Saving billing address failed"
                            if let error = error {
                                print("removePromoCode error: \(error)")
                                errorMessage = ShopifyErrorParser.sharedInstance.getCheckoutErrorMessage(error)
                            }
                            self.presentErrorDialog(error?.code, reason: errorMessage)
                            return
                        }
                        
                        self.transitionViewController()
                    })
                }
            }
            else {
                AppDelegate.hideActivity()
                transitionViewController()
            }
        }
    }
    
    fileprivate func transitionViewController() {
        // Add New Card
        if let _ = confirmAddressAddNewCard {
            let vc = storyboard?.instantiateViewController(withIdentifier: kAddressInfoVCIdentifier) as! AddressInfoVC
            vc.isSaveForLater = isSaveInfoForLater
            vc.model = model
            vc.confirmAddressAddNewCard = confirmAddressAddNewCard
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
            view.endEditing(true)
            navigationController?.pushViewController(vc, animated: true)
        }
        // Update Card
        else if let _ = confirmAddressUpdateCard {
            let vc = storyboard?.instantiateViewController(withIdentifier: kAddressInfoVCIdentifier) as! AddressInfoVC
            vc.isSaveForLater = isSaveInfoForLater
            vc.model = model
            vc.confirmAddressUpdateCard = confirmAddressUpdateCard
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
            view.endEditing(true)
            navigationController?.pushViewController(vc, animated: true)
        }
        else {
            // From Review Order
            if let confirmPaymentFromReviewOrder = confirmPaymentFromReviewOrder {
                confirmPaymentFromReviewOrder(model)
                navigationController?.popViewController(animated: true)
            }
            // Checkout Payment
            else {
                //order.paymentInfo = model
                let vc = storyboard?.instantiateViewController(withIdentifier: kShippingMethodIdentifier) as! ShippingMethodVC
                vc.order = order
                vc.isSaveEnabled = isSaveInfoForLater
                navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        if isSaveInfoForLater == true {
            //model.secureSave()
        }
    }
    
    func cardNumberUpdated(_ textField : UITextField) {
        model.creditCardNumber = textField.text!
        checkIfContinueIsEnabled()
    }
    
    func cvcUpdated(_ textField : UITextField) {
        model.cvc = textField.text!
        checkIfContinueIsEnabled()
    }
    
    func checkIfContinueIsEnabled(){
        if model.creditCardNumber.isEmpty == false && model.cvc.isEmpty == false {
            continueButton.isEnabled = true
            continueButtonView.alpha = 1
        } else {
            continueButton.isEnabled = false
            continueButtonView.alpha = 0.5
        }
    }
    
    func setPlaceHolder( _ textView : UITextView){
        let placeholderTextShelf = "Shelf2016"
        if textView.text.isEmpty {
            setAttributes(textView)
            textView.text = placeholderTextShelf
            textView.textColor = UIColor(colorLiteralRed: 255/255, green: 255/255, blue: 255/255, alpha: 0.1)
        }
    }

    func setAttributes(_ textView : UITextView){
        let font = UIFont(name: "Avenir-Black", size: 12)
        let color = UIColor(colorLiteralRed: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        let attributes : [String : AnyObject] = [NSForegroundColorAttributeName: color, NSKernAttributeName : 0.6 as AnyObject ,NSFontAttributeName : font!]
        textView.typingAttributes = attributes
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension PaymentVC : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Add New Card
        if let _ = confirmAddressAddNewCard {
            return 3
        }
        // Update Card
        else if let _ = confirmAddressUpdateCard {
            return 3
        }
        //
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Shows Promo Code
        if indexPath.row == 3 {
            return 73
        }
        // Default
        else {
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: kGenericAddressCellIdentifier) as! GenericAddressCell
                cell.setupCellType(.card)
                cell.userContent.text = model.creditCardNumber
                cell.userContent.addTarget(self, action: #selector(PaymentVC.cardNumberUpdated(_:)), for: .editingChanged)
                cell.userContent.becomeFirstResponder()
                textField = cell.userContent
                cell.selectionStyle = .none
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: kGenericTwoFieldAddressCellIdentifier) as! GenericTwoFieldAddressCell
                cell.setupCellType(.expirationCVC)
                let picker = MonthYearPickerView()
                picker.onDateSelected = { (month: Int, year: Int) in
                    let string = String(format: "%02d/%d", month, year)
                    cell.firstUserField.text = string
                    self.model.expires = string
                    self.checkIfContinueIsEnabled()
                }
                cell.firstUserField.inputView = picker
                cell.firstUserField.text = model.expires
                
                cell.secondUserField.addTarget(self, action: #selector(PaymentVC.cvcUpdated(_:)), for: .editingChanged)
                cell.secondUserField.keyboardType = .numberPad
                cell.secondUserField.text = model.cvc
                cell.selectionStyle = .none
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: kCreditCardsAcceptedCellIdentifier)
                cell!.selectionStyle = .none
                return cell!
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: kPromoCodeCellIdentifier) as! PromoCodeCell
                cell.promoCode.delegate = self
                cell.promoCode.tag = kPromoTag
                setAttributes(cell.promoCode)
                cell.promoCode.text = model.promoCode
                setPlaceHolder(cell.promoCode)
                cell.promoCode.sizeToFit()
                cell.promoCode.bounces = false
                cell.selectionStyle = .none
                return cell
            default:
                return UITableViewCell()
        }
    }
}

// MARK: - UITextViewDelegate
extension PaymentVC: UITextViewDelegate {
    func textViewDidBeginEditing( _ textView: UITextView) {
        if textView.textColor == UIColor(colorLiteralRed: 255/255, green: 255/255, blue: 255/255, alpha: 0.1) {
            textView.text = nil
            textView.textColor = UIColor.white
            setAttributes(textView)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        setAttributes(textView)
        textView.layoutIfNeeded()
        model.promoCode = textView.text!
        checkIfContinueIsEnabled()
    }
    
    func textViewDidEndEditing( _ textView: UITextView) {
        setPlaceHolder(textView)
    }
}
