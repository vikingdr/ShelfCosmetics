//
//  FullColorProfileVC.swift
//  Shelf
//
//  Created by Matthew James on 8/13/15.
//  Copyright (c) 2015 Shelf. All rights reserved.
//

import UIKit
import Parse
import ParseUI
class FullColorProfileVC: BaseVC {
    
    var color: SColor?
    var brandColor: SBrandColor?
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buyNowBottonBottomView: UIView!
    @IBOutlet weak var buyNowButtonView: UIView!
    @IBOutlet weak var buyNowButton: ShelfButton!
    
    var topBorder: CALayer!
    var bottomBorder: CALayer!
    var imageLabel: UILabel!
    
    override func viewDidLoad() {
        setupNavigationBar()
        setupBackgroundView()
        setupTableView()
        
        
        if let brandColor = color?.brand_color {
            do {
                try brandColor.fetchIfNeeded()
            } catch {
                
            }
            
            self.brandColor = SBrandColor(data: brandColor)
            setupBottomBar()
        }
        else {
            setupBottomBar()
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.imagefooter!.isHidden = true
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.imagefooter!.isHidden = false
        tabBarController?.tabBar.isHidden = false
    }
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
    
    // MARK: - Setup helper functions
    override func setupNavigationBar() {
        super.setupNavigationBar()
        title = "Color Profile"
        
        let rightBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 17, height: 17))
        rightBtn.setImage(UIImage(named: "plus"), for: UIControlState())
        //rightBtn.addTarget(self, action: #selector(BaseVC.cancelPressed), forControlEvents: .TouchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBtn)
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        
        
    }
    
    fileprivate func setupBackgroundView() {
        var imageName = "ColorProfileBackground"
        getDeviceBackgroundImageName(&imageName)
        backgroundImageView.image = UIImage(named: imageName)
    }
    
    fileprivate func setupTableView() {
        tableView.register(UINib(nibName: "ColorProfileCell", bundle: nil), forCellReuseIdentifier: "ColorProfileCell")
        tableView.estimatedRowHeight = 750
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 101, 0)
        tableView.separatorStyle = .none
    }
    
    fileprivate func setupBottomBar() {
        buyNowButtonView.roundAndAddDropShadow(8, shadowOpacity: 0.15, width: 0, height: 1, shadowRadius: 1)
        buyNowButton.setBackgroundColor(UIColor.init(white: 1, alpha: 0.3), forState: .highlighted)
        buyNowButton.layer.cornerRadius = 8
        buyNowButton.layer.masksToBounds = true
        
        if let brandColor = brandColor {
            if let _ = brandColor.shopifyID {
                buyNowBottonBottomView.isHidden = false
            }
        }
    }
    
    override func backPressed() {
        if self.navigationController != nil && self.navigationController!.viewControllers.count > 1 {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - IBAction delegates
    @IBAction func buyNowButtonPressed(_ sender: AnyObject) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ProductInfoVC") as! ProductInfoVC
        if let id = brandColor?.shopifyID {
            vc.productId = id as NSNumber?
            AnalyticsHelper.sendCustomEvent(kFIREventInitiatePurchase)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension FullColorProfileVC : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let brandColor = brandColor {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ColorProfileCell") as! ColorProfileCell
                cell.updateWithData(brandColor)
                cell.healthInfoButton.addTarget(self, action: #selector(FullColorProfileVC.healthInfoSelected), for: .touchUpInside)
            
            //add label for images
            for view in cell.contentView.subviews {
                
                if view is UILabel {
                    
                    let imgLbl: UILabel = view as! UILabel
                    if imgLbl.text == "SHELFIES WITH THIS COLOR:" {
                        imgLbl.removeFromSuperview()
                    }
                    
                } else if view is UICollectionView {
                    
                    view.removeFromSuperview()
                    
                }
                
            }
            
            imageLabel = UILabel(frame:CGRect(x: tableView.width/2-90  , y: cell.healthRating.frame.origin.y+cell.healthRating.frame.size.height+121, width: 180, height: 14))
            imageLabel.text = "SHELFIES WITH THIS COLOR:"
            imageLabel.textAlignment = NSTextAlignment.center
            imageLabel.font = UIFont(name: "Avenir-Black", size: 11.5)
            imageLabel.textColor = UIColor(red: 240/255, green: 120/255, blue: 126/255, alpha: 1.0)
            cell.contentView.addSubview(imageLabel)
            
            // collection view for images
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            layout.itemSize = CGSize(width: 80, height: 80)
            layout.scrollDirection = UICollectionViewScrollDirection.horizontal

            let collectionView = UICollectionView(frame: CGRect(x: 0, y: imageLabel.frame.origin.y + imageLabel.frame.size.height + 10 , width: tableView.width, height: 100), collectionViewLayout: layout)
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "MyCell")
            collectionView.backgroundColor = UIColor.clear
            collectionView.layer.borderWidth = 1.0
            collectionView.layer.borderColor = UIColor.gray.cgColor
            collectionView.showsVerticalScrollIndicator = false
            collectionView.showsHorizontalScrollIndicator = false
            cell.contentView.addSubview(collectionView)
            
            if constant.DeviceType.IS_IPHONE_6P  {
                
                imageLabel.frame = CGRect(x: tableView.width/2-90,y: cell.healthRating.frame.origin.y+cell.healthRating.frame.size.height+81 , width: 180, height: 14)
                collectionView.frame = CGRect(x: 0, y: imageLabel.frame.origin.y + imageLabel.frame.size.height + 10 , width: tableView.width, height: 100)
            }

            
            
            return cell
        }
        return UITableViewCell()
    }
    
    func healthInfoSelected(){
        
        let sb = UIStoryboard(name: "Settings", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "HealthRatingsVC") as! HealthRatingsVC
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 750
    }
    
    
}

/**
    collection view within tableview
 */

extension FullColorProfileVC: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellView = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath)
        cellView.backgroundColor = UIColor.clear
        
        let imageView:UIImageView = UIImageView(image: UIImage(named: "Sampleimages"))
        imageView.frame = CGRect(x: 0, y: 0, width: cellView.width, height: 80)
        imageView.backgroundColor = UIColor.red
        cellView.contentView.addSubview(imageView)
        
        return cellView
        
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
       // return CGSize(width: tableView.width/2.5, height: 100) // The size of one cell
        return CGSize(width: 80, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }

    

}

