//
//  OrderDetailsVC.swift
//  Shelf
//
//  Created by Matthew James on 10/31/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation
import Buy

let kOrderDetailsVCIdentifier = "OrderDetailsVC"

class OrderDetailsVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewTrailingConstraint: NSLayoutConstraint!
    
    var orderId: NSNumber!
    var sOrder: SOrder!
    var shopifyOrder: ShopifyOrder?
    
    override func viewDidLoad() {
        setupNavigationBar()
        setupTableView()
        loadOrder()
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        title = "Order Details"
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: kOrderDetailsLineCellIdentifier, bundle: nil), forCellReuseIdentifier: kOrderDetailsLineCellIdentifier)
        tableView.register(UINib(nibName: kOrderDetailsInfoCellIdentifier, bundle: nil), forCellReuseIdentifier: kOrderDetailsInfoCellIdentifier)
        tableView.register(UINib(nibName: kOrderDetailsTrackingCellIdentifier, bundle: nil), forCellReuseIdentifier: kOrderDetailsTrackingCellIdentifier)
        tableView.separatorColor = UIColor.init(white: 1, alpha: 0.05)
        
        // if < iPhone 5s
        if UIScreen.main.bounds.width == 320 {
            tableViewLeadingConstraint.constant = 0
            tableViewTrailingConstraint.constant = 0
            view.layoutIfNeeded()
        }
    }
    
    func loadOrder() {
        if let _ = shopifyOrder {
            tableView.reloadData()
        } else {
            AppDelegate.showActivity()
            ShopifyAPI().getOrderWithOrderId(orderId, completion: { (responseObject: AnyObject?) in
                AppDelegate.hideActivity()
                guard let responseObject = responseObject as? [String: AnyObject],
                    let order = responseObject[kShopifyOrder] as? [String: AnyObject] else {
                    return
                }
                
                self.shopifyOrder = ShopifyOrder(JSON: order)
                print("shopifyOrder: \(self.shopifyOrder?.id)")
                self.tableView.reloadData()
                
            })
        }
    }
    
    // MARK: IBAction
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        navigationController?.popViewController(animated: true)
    }
}

extension OrderDetailsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let order = shopifyOrder, let lineItems = order.lineItems {
            print("count: \(lineItems.count)")
            return lineItems.count + 2
        }
        
        return 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if let order = shopifyOrder, let lineItems = order.lineItems {
            if indexPath.row < lineItems.count {
                if indexPath.row == 0 {
                    return 142
                }
                return 93
            } else if indexPath.row == lineItems.count {
                return 806
            }
            
            return 219
        }
        
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let order = shopifyOrder, let lineItems = order.lineItems {
            if indexPath.row < lineItems.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: kOrderDetailsLineCellIdentifier, for: indexPath) as! OrderDetailsLineCell
                cell.updateUI(indexPath.row == 0)
                cell.updateWithData(lineItems[indexPath.row], sOrder: sOrder)
                
                return cell
            }
            // Order Details info cell
            else if indexPath.row == lineItems.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: kOrderDetailsInfoCellIdentifier, for: indexPath) as! OrderDetailsInfoCell
                cell.updateWithData(order)
                return cell
            }
            // Tracking info cell
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: kOrderDetailsTrackingCellIdentifier, for: indexPath) as! OrderDetailsTrackingCell
                return cell
            }
        }
        
        return UITableViewCell()
    }
}
