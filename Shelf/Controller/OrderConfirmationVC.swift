//
//  OrderConfirmationVC.swift
//  Shelf
//
//  Created by Matthew James on 10/25/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation
import Buy

let kOrderConfirmationVCIdentifier = "OrderConfirmationVC"

class OrderConfirmationVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var gotItButtonView: UIView!
    @IBOutlet weak var gotItButton: ShelfButton!
    
    var dismissShoppingCart : (() -> ())?
    
    override func viewDidLoad() {
        setupNavigationBar()
        setupTableView()
        setupBottomBar()
        
        if let usr = PFUser.current(), let checkout = BUYCheckoutManager.sharedInstance.checkout {
            let pfOrder = PFObject(className: "Order")
            pfOrder[kParseUser] = usr
            if let order = checkout.order {
                pfOrder[kParseOrderId] = order.identifier
            }
            
            let items = BUYCart.sharedCart.mutableLineItemsArray()
            var array = [[String : String]]()
            for lineItem in items {
                if let imgLink = lineItem.variant.product.images.firstObject as? BUYImageLink {
                    let url = imgLink.imageURL(with: BUYImageURLSize.size100x100)
                    array.append([kParseId : String(describing: lineItem.variant.product.identifier), kParseKImageUrl: url.absoluteString])
                }
            }
            pfOrder[kParseProducts] = array
            pfOrder.saveInBackground()
        }
    }
    
    // MARK: - Setup helper functions
    func setupNavigationBar() {
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(named: "Navigationbar")!.resizableImage(withCapInsets: UIEdgeInsetsMake(0, 0, 0, 0), resizingMode: .stretch), for: UIBarMetrics.default)
        
        let attributes = [NSFontAttributeName: UIFont(name: "Avenir-Black", size: 16)!,
                    NSForegroundColorAttributeName: UIColor.white,
                    NSKernAttributeName: 0.53] as [String : Any]
        
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        
        self.navigationController?.navigationBar.layer.shadowRadius = 2.0
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.15
        
        title = "Order Confirmation"
        navigationController?.navigationBar.titleTextAttributes = attributes
        
        
        let emptyButton = UIButton(frame: CGRect(x: 0, y: 0, width: 17, height: 17))
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: emptyButton)
        
        let cancelButton = UIButton(frame: CGRect(x: 0, y: 0, width: 17, height: 17))
        cancelButton.setImage(UIImage(named: "cancelButton"), for: UIControlState())
        cancelButton.addTarget(self, action: #selector(OrderConfirmationVC.returnToColorProfile), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: cancelButton)
        
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 63, 0)
        tableView.register(UINib(nibName: kOrderConfirmationCellIdentifier, bundle: nil), forCellReuseIdentifier: kOrderConfirmationCellIdentifier)
        tableView.separatorColor = UIColor.clear
    }
    
    func setupBottomBar() {
        gotItButtonView.roundAndAddDropShadow(8, shadowOpacity: 0.15, width: 0, height: 1, shadowRadius: 1)
        gotItButton.setBackgroundColor(UIColor.init(white: 1, alpha: 0.3), forState: .highlighted)
        gotItButton.layer.cornerRadius = 8
        gotItButton.layer.masksToBounds = true
    }
    
    // MARK: - IBAction
    @IBAction func gotItButtonPressed(_ sender: AnyObject) {
        returnToHomeVC()
    }
    
    // MARK: -
    func returnToColorProfile() {
        BUYCart.sharedCart.clearExistingCart()
        BUYCheckoutManager.sharedInstance.clearCheckout()
        dismiss(animated: true) {
            if let dismissShoppingCart = self.dismissShoppingCart {
                dismissShoppingCart()
            }
        }
    }
    
    func returnToHomeVC() {
        BUYCart.sharedCart.clearExistingCart()
        BUYCheckoutManager.sharedInstance.clearCheckout()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.dismiss(animated: true) {
            UIView.animate(withDuration: 0.1, animations: {
                appDelegate.window?.alpha = 0
                }, completion: { (completed) in
                    appDelegate.showContent()
                    UIView.animate(withDuration: 0.1, animations: {
                        appDelegate.window?.alpha = 1
                        }, completion: { (completed) in
                    })
            })
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension OrderConfirmationVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 518
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kOrderConfirmationCellIdentifier, for: indexPath) as! OrderConfirmationCell
        if let checkout = BUYCheckoutManager.sharedInstance.checkout {
            cell.updateWithData(checkout)
        }
        return cell
    }
}
