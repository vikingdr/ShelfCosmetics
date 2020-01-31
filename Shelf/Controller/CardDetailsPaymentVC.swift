//
//  CardDetailsPaymentVC.swift
//  Shelf
//
//  Created by Nathan Konrad on 11/7/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import UIKit

class CardDetailsPaymentVC: UIViewController {

    @IBOutlet weak var continueAddress: ShelfButton!
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var bottomTableViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomViewConstraint: NSLayoutConstraint!
    
    @IBAction func makeDefaultChanged(_ sender: AnyObject) {
        makeDefault = !makeDefault
    }
    
    @IBAction func continueAddressPressed(_ sender: AnyObject) {
        let vc = storyboard?.instantiateViewController(withIdentifier: kAddressInfoVCIdentifier) as! AddressInfoVC
//        vc.isAddEditPayment = true
        navigationController?.pushViewController(vc, animated: true)
    }
    var model : PaymentInfoModel!
    var makeDefault = true
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(CardDetailsPaymentVC.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(CardDetailsPaymentVC.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(CardDetailsPaymentVC.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        checkIfContinueIsEnabled()
        
        title = "Card Details"
        
        setupTableView()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        setupBackButton()
        
    }
    

    
    override func backPressed(){
        navigationController?.popViewController(animated: true)
    }
    
    func dismissKeyboard(){
        view.endEditing(true)
    }

    func keyboardWillShow (_ notification: Notification){
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
    
    func keyboardWillHide (_ notification: Notification){
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
    
    func setupTableView(){
        tableView.register(UINib(nibName: "PromoCodeCell", bundle: nil), forCellReuseIdentifier: "PromoCodeCell")
        tableView.register(UINib(nibName: "CreditCardsAcceptedCell", bundle: nil), forCellReuseIdentifier: "CreditCardsAcceptedCell")
        tableView.register(UINib(nibName: "GenericAddressCell", bundle: nil), forCellReuseIdentifier: "GenericAddressCell")
        tableView.register(UINib(nibName: "GenericTwoFieldAddressCell", bundle: nil), forCellReuseIdentifier: "GenericTwoFieldAddressCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
    }
    

    func cardNumberUpdated(_ textField : UITextField){
        model.creditCardNumber = textField.text!
        checkIfContinueIsEnabled()
    }
    
    func cvcUpdated(_ textField : UITextField){
        model.cvc = textField.text!
        checkIfContinueIsEnabled()
    }
    
    func promoCodeUpdated(_ textField : UITextField){
        model.promoCode = textField.text!
        checkIfContinueIsEnabled()
    }
    
    func checkIfContinueIsEnabled(){
        if model.creditCardNumber.isEmpty == false && model.cvc.isEmpty == false {
            continueAddress.isEnabled = true
        }else{
            continueAddress.isEnabled = false
        }
    }
    
}


extension CardDetailsPaymentVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "GenericAddressCell") as! GenericAddressCell
            cell.setupCellType(.card)
            cell.userContent.text = model.creditCardNumber
            
            cell.userContent.addTarget(self, action: #selector(CardDetailsPaymentVC.cardNumberUpdated(_:)), for: .editingChanged)
            cell.selectionStyle = .none
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "GenericTwoFieldAddressCell") as! GenericTwoFieldAddressCell
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
            
            cell.secondUserField.addTarget(self, action: #selector(CardDetailsPaymentVC.cvcUpdated(_:)), for: .editingChanged)
            cell.secondUserField.keyboardType = .numberPad
            cell.secondUserField.text = model.cvc
            
            cell.selectionStyle = .none
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CreditCardsAcceptedCell")
            cell!.selectionStyle = .none
            return cell!
            /*
        case 3:
            let cell = tableView.dequeueReusableCellWithIdentifier("PromoCodeCell") as! PromoCodeCell
            cell.promoCode.addTarget(self, action: #selector(PaymentVC.promoCodeUpdated(_:)), forControlEvents: .EditingChanged)
            cell.promoCode.text = model.promoCode
            cell.selectionStyle = .None
            return cell
 */
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 3 {
            return 73
        }else{
            return 50
        }
    }
}
