//
//  EditYourColorsVC.swift
//  Shelf
//
//  Created by Matthew James on 11/6/15.
//  Copyright © 2015 Shelf. All rights reserved.
//

import UIKit

let kRemoveShelfiesVCIdentifier = "EditYourColorsVC"

class EditYourColorsVC : BaseVC, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var data : [SColor] = []
    var refreshControl: UIRefreshControl!
    
    // MARK: - View Life cycle methods
    override func viewDidLoad() {
        setupNavigationBar()
        setupCollectionView()
        
        // Get data
        reloadData()
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        title = "Remove SHELFIES"
    }
    
    func setupCollectionView() {
        // UICollectionView
        collectionView?.backgroundColor = nil
        collectionView?.backgroundView = nil
        collectionView?.scrollsToTop = true
        collectionView?.scrollIndicatorInsets.top = 20.0
        collectionView?.register(UINib(nibName: "EditColorCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ColorCell")
        
        let inset = UIEdgeInsetsMake(0, 0, 30, 0)
        collectionView?.contentInset = inset
        
        // UIRefreshControl
        let attrText = NSMutableAttributedString(string: "Pull to refresh")
        let range = NSMakeRange(0, attrText.length)
        attrText.addAttribute(NSForegroundColorAttributeName, value: UIColor.init(white: 1, alpha: 0.6), range: range)
        attrText.addAttribute(NSFontAttributeName, value: UIFont(name: "Avenir-Black", size: 12)!, range: range)
        
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.init(white: 1, alpha: 0.6)
        refreshControl.attributedTitle = attrText
        refreshControl.addTarget(self, action: #selector(EditYourColorsVC.reloadData), for: UIControlEvents.valueChanged)
        collectionView?.addSubview(refreshControl)
        
        // This is needed if the collection is not big enough to have an active scrollbar
        collectionView?.alwaysBounceVertical = true;
    }
    
    // MARK: - Data
    func reloadData() {
        AppDelegate.showActivity()
        
        let query = PFQuery(className: "Color")
        query.whereKey("createdBy", equalTo: PFUser.current()!)
        query.order(byDescending: "createdAt")
        
        self.data = []
        
        query.findObjectsInBackground { (array, error) -> Void in
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background).async(execute: { () -> Void in
                if (error == nil)
                {
                    for object in array! {
                        let color = SColor(data:object)
                        self.data.append(color)
                    }
                }
                
                DispatchQueue.main.async(execute: {
                    AppDelegate.hideActivity()
                    self.collectionView?.reloadData()
                    self.refreshControl.endRefreshing()
                })
            })
        }
    }
    
    // MARK: - Actions
    func deleteButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Delete Color", message: "Are you sure?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.default, handler: { (UIAlertAction) -> Void in
            AppDelegate.showActivity()
            let color = self.data[sender.tag]
            color.object?.deleteInBackground(block: { (success, error) -> Void in
                if error == nil && success == true {
                    self.reloadData()
                    
                    // Nodify
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "colorDeleted"), object: color)
                    
                } else {
                    assert(false, "failed to delete color")
                }
                
                AppDelegate.hideActivity()
            })
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - UICollectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
            
        case UICollectionElementKindSectionHeader:
            let headerView: EditColorsHeaderCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind,withReuseIdentifier: "EditColorsHeaderCell", for: indexPath) as! EditColorsHeaderCell
            
            return headerView as UICollectionReusableView
            
        default:
            assert(false, "Unexpected element kind")
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let collectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as! EditColorCollectionViewCell
        
        let color : SColor = data[indexPath.item]
        collectionViewCell.color = color
        collectionViewCell.deleteButton.tag = indexPath.item
        collectionViewCell.deleteButton.addTarget(self, action: #selector(EditYourColorsVC.deleteButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        
        return collectionViewCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width/3, height: self.view.frame.width/3)
    }
}
