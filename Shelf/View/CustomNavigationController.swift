//
//  CustomNavigationController.swift
//  Shelf
//
//  Created by Matthew James on 6/16/15.
//  Copyright (c) 2015 Shelf. All rights reserved.
//

class CustomNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.navigationBar.setBackgroundImage(UIImage(named: "Navigationbar"), forBarMetrics: UIBarMetrics.Default)
        navigationBar.isOpaque = true
        navigationBar.barTintColor = UIColor.white
        navigationBar.isTranslucent = false
        
        let titleView:UIImageView = UIImageView(image: UIImage(named: "Registation_logo"))
        titleView.frame = CGRect(x: 0,y: 0,width: 200,height: 100)
        self.navigationItem.titleView = titleView
        
        let inviteFriendsButton = UIBarButtonItem()
        inviteFriendsButton.image = UIImage(named: "btnAddFriends")
        
        let settingsButton = UIBarButtonItem()
        settingsButton.image = UIImage(named: "btnSettings")
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "btnInviteFriends"), style: .plain, target: self, action: #selector(CustomNavigationController.test))
        
        //Removes shadow in nav bar
        for parent in self.navigationBar.subviews {
            for childView in parent.subviews {
                if(childView is UIImageView) {
                    
                    childView.removeFromSuperview()
                    
                }
            }
        }
    }
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return (topViewController?.preferredStatusBarStyle)!
	}
    
    func test() {
        
    }
}
