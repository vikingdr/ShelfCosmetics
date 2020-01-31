//
//  ProductInfoVC.swift
//  Shelf
//
//  Created by Nathan Konrad on 10/20/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import UIKit
import Buy
import Kingfisher
import MBProgressHUD
import Firebase

let kProductInfoVCIdentifier = "ProductInfoVC"

class ProductInfoVC: BaseVC {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addToCartButtonView: UIView!
    @IBOutlet weak var addToCartButton: ShelfButton!
    @IBOutlet weak var addToCartLabel: ShelfLabel!

    var productId : NSNumber?
    var index: Int?
    var updateCartAtIndex: ((Int?, Bool) -> ())?
    
    fileprivate var currentProduct : BUYProduct?
    fileprivate var currentProductVariant : BUYProductVariant?
    fileprivate var quantity: UInt64 = 1
    fileprivate var productQuantityLabel : UILabel!
    
    override func viewDidLoad() {
        setupNavigationBar()
        setupTableView()
        setupBottomBar()
        
        if let index = index, index < BUYCart.sharedCart.mutableLineItemsArray().count {
            let currentLineItem = BUYCart.sharedCart.mutableLineItemsArray()[index]
            
            currentProductVariant = currentLineItem.variant
            currentProduct = currentLineItem.variant.product
            quantity = currentLineItem.quantity.uint64Value
            reloadTableView()
            addToCartButton.isHidden = false
        }
        // No current product, fetch product if has id
        else {
            if let productId = productId {
                AppDelegate.showActivity()
                BUYClient.sharedClient.getProductById(productId, completion: { (product, error) in
                    AppDelegate.hideActivity()
                    guard error == nil , let product = product else {
                        print("error occurred: " + error!.localizedDescription)
                        self.presentErrorDialog()
                        return
                    }
                    
                    self.currentProduct = product
                    self.currentProductVariant = product.variants.firstObject as? BUYProductVariant
                    print("currentProductVariant: \(self.currentProductVariant!.available)")
                    self.reloadTableView()
                    self.addToCartButton.isHidden = false
                })
            }
        }
    }
    
    func presentErrorDialog() {
        let alertC = UIAlertController(title: "Error", message: "An error occurred while fetching the product, please try again later.", preferredStyle: .alert)
        alertC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertC, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.imagefooter!.isHidden = true
        tabBarController?.tabBar.isHidden = true
        
        setupShoppingCartIcon()
        reloadTableView()
    }
    
    // MARK: - Setup helper functions
    override func setupNavigationBar() {
        super.setupNavigationBar()
        title = "Product Info"
    }
    
    fileprivate func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: kProductInfoCellIdentifier, bundle: nil), forCellReuseIdentifier: kProductInfoCellIdentifier)
        tableView.estimatedRowHeight = 840
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 127, 0)
        tableView.separatorStyle = .none
    }
    
    fileprivate func setupBottomBar() {
        addToCartButtonView.roundAndAddDropShadow(8, shadowOpacity: 0.15, width: 0, height: 1, shadowRadius: 1)
        addToCartButton.setBackgroundColor(UIColor(hex: 0xFFFFFF, alpha: 0.3), forState: .highlighted)
        addToCartButton.layer.cornerRadius = 8
        addToCartButton.layer.masksToBounds = true
    }
    
    fileprivate func setupShoppingCartIcon() {
        if let _ = updateCartAtIndex {
            
        } else {
            let cart = Bundle.main.loadNibNamed(kShoppingCartViewIdentifier, owner: self, options: nil)?.first as! ShoppingCartView
            cart.countOfItems.text = "\(BUYCart.sharedCart.mutableLineItemsArray().count)"
            let tap = UITapGestureRecognizer(target: self, action: #selector(ProductInfoVC.openShoppingCart))
            tap.numberOfTapsRequired = 1
            cart.addGestureRecognizer(tap)
            
            let barButtonItem = UIBarButtonItem(customView: cart)
            self.navigationItem.rightBarButtonItem = barButtonItem
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        }
    }
    
    fileprivate func reloadTableView() {
        // Check if Product exists in Cart, change text to Update Cart
        if let _ = BUYCart.sharedCart.checkVariantExistInCart(currentProductVariant) {
            // Update button text to Update Cart
            addToCartLabel.updateAttributedTextWithString("UPDATE CART")
        }
        
        tableView.reloadData()
    }
    
    func openShoppingCart() {
        let vc = storyboard?.instantiateViewController(withIdentifier: kShoppingCartVCIdentifier) as! ShoppingCartVC
        vc.dismissVC = popViewController
        let nav = NickNavViewController(rootViewController: vc)
        nav.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        self.present(nav, animated: true, completion: nil)
    }
    
    fileprivate func popViewController(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func minusButtonPressed(_ sender: AnyObject) {
        quantity -= 1
        
        if quantity < 1 {
            quantity = 1
        }
        
        productQuantityLabel.text = "\(quantity)"
    }
    
    @IBAction func plusButtonPressed(_ sender: AnyObject) {
        quantity += 1
        
        productQuantityLabel.text = "\(quantity)"
    }

    @IBAction func addToCartPressed(_ sender: AnyObject) {
        if let variant = currentProductVariant {
            BUYCart.sharedCart.setVariantToExisting(variant, withTotalQuantity: quantity)
            // From Shopping Cart
            if let updateCartAtIndex = updateCartAtIndex {
                updateCartAtIndex(index, false)
                backPressed()
            }
            // From Color Profile, transition to Shopping Cart
            else {
                let scView = self.navigationItem.rightBarButtonItem?.customView as! ShoppingCartView
                scView.countOfItems.text = "\(BUYCart.sharedCart.mutableLineItemsArray().count)"
                AnalyticsHelper.sendCustomEvent(kFIREventAddToCart)
                openShoppingCart()
            }
        }
    }
}

extension ProductInfoVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let _ = currentProduct {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return createProductInfoCell()
    }
    
    func createProductInfoCell() -> ProductInfoCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kProductInfoCellIdentifier) as! ProductInfoCell
        productQuantityLabel = cell.productCountLabel
        if let product = currentProduct {
            cell.updateWithData(product)
        }
        cell.minusButton.addTarget(self, action: #selector(ProductInfoVC.minusButtonPressed(_:)), for: .touchUpInside)
        cell.plusButton.addTarget(self, action: #selector(ProductInfoVC.plusButtonPressed(_:)), for: .touchUpInside)
        productQuantityLabel.text = "\(quantity)"
        return cell
    }
}
