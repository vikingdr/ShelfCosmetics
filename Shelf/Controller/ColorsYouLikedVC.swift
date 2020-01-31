//
//  ColorsYouLikedVC.swift
//  Shelf
//
//  Created by Nathan Konrad on 8/5/15.
//  Copyright (c) 2015 Shelf. All rights reserved.
//

import UIKit

class ColorsYouLikedVC: BaseVC,UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    @IBOutlet var collectionView:UICollectionView?
    var data : [SColor] = []
    var refreshControl: UIRefreshControl!
    
    // MARK: - View Life cycle methods
    override func viewDidLoad() {
        setupNavigationBar()
        setupCollectionView()
        
        reloadData()
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        title = "SHELFIES I've Liked"
    }
    
    func setupCollectionView() {
        collectionView?.backgroundColor = nil
        collectionView?.backgroundView = nil
        collectionView?.scrollsToTop = true
        collectionView?.scrollIndicatorInsets.top = 20.0
        
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
        refreshControl.addTarget(self, action: #selector(ColorsYouLikedVC.reloadData), for: UIControlEvents.valueChanged)
        collectionView?.addSubview(refreshControl)
        
        // This is needed if the collection is not big enough to have an active scrollbar
        collectionView?.alwaysBounceVertical = true;
    }
    
    func reloadData () {
        AppDelegate.showActivity()
        
        let query = PFQuery(className: "Like")
        query.whereKey("user", equalTo: PFUser.current()!)
        query.includeKey("color")
        query.order(byDescending: "createdAt")
        
        self.data = []
        
        query.findObjectsInBackground { (array, error) -> Void in
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background).async(execute: { () -> Void in
                if (error == nil)
                {
                    for object in array! {
                        let colorPFObject = object["color"] as! PFObject
                        let color = SColor(data:colorPFObject)
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
            
        case UICollectionElementKindSectionHeader:
            let headerView: ColorsYouLikedHeaderCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind,withReuseIdentifier: "ColorsYouLikedHeaderCell", for: indexPath) as! ColorsYouLikedHeaderCell
            
            return headerView as UICollectionReusableView
            
        default:
            assert(false, "Unexpected element kind")
        }
        return UICollectionReusableView()
    }
    
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let collectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCell", for: indexPath) as! SearchCell
        collectionViewCell.backgroundColor = UIColor(patternImage: UIImage(named: "bg_profile")!)
        
        let color : SColor = data[indexPath.row]
        collectionViewCell.color = color
//        collectionViewCell.contentImage.alpha = 0
//        collectionViewCell.contentImage?.file = color.imageFile
//        collectionViewCell.contentImage?.loadInBackground({ (image, error) -> Void in
//            collectionViewCell.contentImage!.image = image
//            UIView.animateWithDuration(0.2, animations: { () -> Void in
//                collectionViewCell.contentImage.alpha = 1
//            })
//        })
//        collectionViewCell.contentImage.alpha = 0
//        collectionViewCell.setSColor(color)
        
        
        return collectionViewCell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell : SearchCell = collectionView.cellForItem(at: indexPath) as! SearchCell
        self.showColorDetailsForColor(cell.color!)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width/3, height: self.view.frame.width/3)
    }
    
    func showColorDetailsForColor(_ color : SColor) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: ColorDetailsVC = storyboard.instantiateViewController(withIdentifier: "ColorDetailsVC") as! ColorDetailsVC
        vc.color = color
        let navController = NickNavViewController(rootViewController: vc)
        self.present(navController, animated:true, completion: nil)
    }
    
}
