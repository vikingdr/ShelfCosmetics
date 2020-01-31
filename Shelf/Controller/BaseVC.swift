//
//  BaseVC.swift
//  Shelf
//
//  Created by Nathan Konrad on 30.06.15.
//  Copyright (c) 2015 Shelf. All rights reserved.
//

import UIKit
// create base controller for setup navigation bar
class BaseVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavBar()
    }

    func setupNavigationBar() {        
        navigationController!.navigationBar.setBackgroundImage(UIImage(named: "Navigationbar")!.resizableImage(withCapInsets: UIEdgeInsetsMake(0, 0, 0, 0), resizingMode: .stretch), for: UIBarMetrics.default)
        
        navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        
        navigationController?.navigationBar.layer.shadowRadius = 2.0
        navigationController?.navigationBar.layer.shadowOpacity = 0.15
        navigationController?.navigationBar.shadowImage = UIImage()
        
        let attributes = [NSFontAttributeName: UIFont(name: "Avenir-Black", size: 16)!,
                          NSForegroundColorAttributeName: UIColor.white,
                          NSKernAttributeName: 0.53] as [String : Any]
        navigationController?.navigationBar.titleTextAttributes = attributes
        
        
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 18))
        backButton.setImage(UIImage(named: "backButton"), for: UIControlState())
        backButton.addTarget(self, action: #selector(BaseVC.backPressed), for: .touchUpInside)
        let backButtonItem = UIBarButtonItem(customView: backButton)
        backButtonItem.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = backButtonItem
        
        let emptyButton = UIButton(frame: CGRect(x: 0, y: 0, width: 17, height: 17))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: emptyButton)
    }
    
    func setupNavBar() {
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(named: "Navigationbar")!.resizableImage(withCapInsets: UIEdgeInsetsMake(0, 0, 0, 0), resizingMode: .stretch), for: UIBarMetrics.default)
        
        let titleView:UIImageView = UIImageView(image: UIImage(named: "Registation_logo"))
        titleView.contentMode = UIViewContentMode.scaleAspectFit
        titleView.frame = CGRect(x: 0, y: 0, width: 35.0, height: 30.0)
        self.navigationItem.titleView = titleView
        
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 18))
        backButton.setImage(UIImage(named: "backButton"), for: UIControlState())
        backButton.addTarget(self, action: #selector(BaseVC.backPressed), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)

        let cancelButton = UIButton(frame: CGRect(x: 0, y: 0, width: 17, height: 17))
        cancelButton.setImage(UIImage(named: "cancelButton"), for: UIControlState())
        cancelButton.addTarget(self, action: #selector(BaseVC.cancelPressed), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: cancelButton)
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
    }
    
    override func backPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func cancelPressed() {
        self.dismiss(animated: true, completion: nil)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.imagefooter?.isHidden = false
    }

}
