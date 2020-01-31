//
//  OrderHistoryVC.swift
//  Shelf
//
//  Created by Nathan Konrad on 10/31/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation
import DZNEmptyDataSet
import Buy

let kOrderHistoryVCIdentifier = "OrderHistoryVC"

class OrderHistoryVC: BaseVC {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var collectionViewSize: CGSize = CGSize.zero
    
    override func viewDidLoad() {
        setupNavigationBar()
        setUpCollectionView()
        OrderHistory.sharedHistory.reset()
        loadOrders()
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        title = "Order History"
    }
    
    func setUpCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.emptyDataSetSource = self
        collectionView.emptyDataSetDelegate = self
        collectionView.register(UINib(nibName: kOrderHistoryCellIdentifier, bundle: nil), forCellWithReuseIdentifier: kOrderHistoryCellIdentifier)
        collectionView.register(UINib(nibName: kLoadingMoreCollectionViewCellIdentifier, bundle: nil), forCellWithReuseIdentifier: kLoadingMoreCollectionViewCellIdentifier)
        collectionView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0)
        let width = (UIScreen.main.bounds.width - 66) / 2
        collectionViewSize = CGSize(width: width, height: 167)
    }
    
    // MARK: - IBAction
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - 
    fileprivate func loadOrders() {
        if OrderHistory.sharedHistory.currentOrders().count == 0 {
            AppDelegate.showActivity()
            OrderHistory.sharedHistory.updateOrders(completion: { (success: Bool, shouldLoadNextPage: Bool) in
                AppDelegate.hideActivity()
                guard success == true else {
                    return
                }
                
                self.collectionView.reloadData()
            })
        } else {
            collectionView.reloadData()
        }
    }
    
    fileprivate func loadNextPage() {
        let page = OrderHistory.sharedHistory.currentOrdersPages()[OrderHistory.sharedHistory.currentOrdersPages().count - 1] + 1
        OrderHistory.sharedHistory.updateOrders(page, itemPerPage: kOrdersPerPage) { (success, shouldLoadNextPage) in
            guard success == true else {
                return
            }
            
            let start = page * kItemsPerPage
            var end = start + kItemsPerPage
            if end > OrderHistory.sharedHistory.currentOrders().count {
                end = OrderHistory.sharedHistory.currentOrders().count
            }
            var insertIndexPaths = [IndexPath]()
            if end > start {
                for index in start..<end {
                    if index == start {
                        if OrderHistory.sharedHistory.shouldLoadnextPage() {
                            insertIndexPaths.append(IndexPath(item: index, section: 0))
                        }
                    } else {
                        insertIndexPaths.append(IndexPath(item: index, section: 0))
                    }
                }
            }
            
            if !OrderHistory.sharedHistory.shouldLoadnextPage() {
                self.collectionView.performBatchUpdates({ 
                    self.collectionView.reloadItems(at: [IndexPath(item: start, section: 0)])
                    self.collectionView.insertItems(at: insertIndexPaths)
                    }, completion: { (success: Bool) in
                        guard success == true else {
                            return
                        }
                })
            }
            else {
                self.collectionView.insertItems(at: insertIndexPaths)
            }
        }
    }
}

extension OrderHistoryVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = OrderHistory.sharedHistory.currentOrders().count
        if OrderHistory.sharedHistory.shouldLoadnextPage() {
            count += 1
        }
        
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item < OrderHistory.sharedHistory.currentOrders().count {
            // First two rows
            if indexPath.item < 2 {
                return CGSize(width: collectionViewSize.width, height: 179)
            }
            
            return collectionViewSize
        }
        // Return LoadingMoreCollectionViewCell full width
        else {
            return CGSize(width: UIScreen.main.bounds.width - 44, height: 69)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.minimumInteritemSpacing = 22
        }
        return UIEdgeInsetsMake(0, 22, 0, 22)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item < OrderHistory.sharedHistory.currentOrders().count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kOrderHistoryCellIdentifier, for: indexPath) as! OrderHistoryCell
            cell.updateWithData(OrderHistory.sharedHistory.currentOrders()[indexPath.item])
            return cell
        }
        // Return LoadingMoreCollectionViewCell
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kLoadingMoreCollectionViewCellIdentifier, for: indexPath) as! LoadingMoreCollectionViewCell
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let orderId = OrderHistory.sharedHistory.currentOrders()[indexPath.item].orderId {
            let vc = storyboard?.instantiateViewController(withIdentifier: kOrderDetailsVCIdentifier) as! OrderDetailsVC
            vc.orderId = orderId
            vc.sOrder = OrderHistory.sharedHistory.currentOrders()[indexPath.item]
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == OrderHistory.sharedHistory.currentOrders().count - 1 {
            if OrderHistory.sharedHistory.shouldLoadnextPage() {
                loadNextPage()
            }
        }
    }
}

extension OrderHistoryVC: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func customView(forEmptyDataSet scrollView: UIScrollView!) -> UIView! {
        if OrderHistory.sharedHistory.currentOrdersPages().count == 0 || (OrderHistory.sharedHistory.currentOrders().count == 0 && OrderHistory.sharedHistory.shouldLoadnextPage() == false) {
            let backgroundView = Bundle.main.loadNibNamed(kOrderHistoryEmptyBackgroundIdentifier, owner: self, options: nil)?.first as! UIView
            backgroundView.frame = collectionView.frame
            backgroundView.center = collectionView.center
            return backgroundView
        }
        
        return UIView()
    }
}
