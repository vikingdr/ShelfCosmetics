//
//  AddEditPaymentVC.swift
//  Shelf
//
//  Created by Nathan Konrad on 11/6/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
class AddEditPaymentVC: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    var model : CreditCardManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupNavBar()
        title = "Add/Edit Payment"
        collectionView.emptyDataSetSource = self
        collectionView.emptyDataSetDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        model = CreditCardManager.sharedInstance
        if model.cards.count <= 0 {
             let gr = UITapGestureRecognizer(target: self, action: #selector(AddEditPaymentVC.addCardTapped))
             self.view.addGestureRecognizer(gr)
        }
        collectionView.reloadData()
    }
    
    func addCardTapped() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "PaymentVC") as! PaymentVC
        let cc = CreditCard()
        vc.confirmAddressAddNewCard = newCardAdded
//        vc.isAddPayment = true
        vc.model = cc
        navigationController?.pushViewController(vc, animated: true)
  
    }
    
    func setupNavBar() {
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 18))
        backButton.setImage(UIImage(named: "backButton"), for: UIControlState())
        backButton.addTarget(self, action: #selector(AddEditPaymentVC.backPressed), for: .touchUpInside)
        let backButtonItem = UIBarButtonItem(customView: backButton)
        backButtonItem.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = backButtonItem
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        
        let emptyButton = UIButton(frame: CGRect(x: 0, y: 0, width: 17, height: 17))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: emptyButton)
    }
    
    func setupCollectionView() {
        collectionView.register(UINib(nibName: "AddCardCell", bundle: nil), forCellWithReuseIdentifier: "AddCardCell")
        collectionView.register(UINib(nibName: "CreditCardCell", bundle: nil), forCellWithReuseIdentifier: "CreditCardCell")
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func backPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Callback functions
    func newCardAdded() {
        collectionView.reloadData()
    }
    
    func cardUpdatedAtIndex(_ index: Int) {
        collectionView.reloadItems(at: [IndexPath(item: 0, section: 0)])
    }
}

extension AddEditPaymentVC : UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = model.cards.count
        if count == 0 {
            return 0
        }
        return count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPlath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width
        let cellWidth : CGFloat = (width - 84) / 2
        let size = CGSize(width: cellWidth, height: 156)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == model.cards.count  {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddCardCell" ,for: indexPath) as! AddCardCell
        return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CreditCardCell" ,for: indexPath) as! CreditCardCell
            
            cell.setupCell(model.cards[indexPath.row])
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.minimumInteritemSpacing = 24
        }
        return UIEdgeInsetsMake(30, 30, 0, 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == model.cards.count {
            addCardTapped()
        }else{
            let vc = storyboard?.instantiateViewController(withIdentifier: "PaymentVC") as! PaymentVC
            vc.confirmAddressUpdateCard = cardUpdatedAtIndex
//            vc.isEditPayment = true
//            vc.indexToEdit = indexPath.row
            let card = model.cards[indexPath.row]
  
            print("selected \(card.creditCardNumber) ")
             print("\(card.isDefaultCreditCard) ")
            vc.model = card
            vc.isSaveInfoForLater = card.isDefaultCreditCard
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension AddEditPaymentVC : DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    func customView(forEmptyDataSet scrollView: UIScrollView!) -> UIView! {
        let backgroundView = Bundle.main.loadNibNamed("AddEditPaymentEmptyBackground", owner: self, options: nil)?.first as! AddEditPaymentEmptyBackground
        backgroundView.frame = collectionView.frame
        backgroundView.center = collectionView.center
        return backgroundView
        
    }
    
}
