//
//  HelpCenterVC.swift
//  Shelf
//
//  Created by Nathan Konrad on 11/8/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import UIKit

class HelpCenterVC: UIViewController {

    @IBAction func faqPressed(_ sender: UIButton) {
        sender.backgroundColor = UIColor(r: 255, g: 182, b: 96)

        UIView.animate(withDuration: 0.5, animations: {
            sender.backgroundColor = UIColor.clear
        }) 
        
        let vc = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: "FAQVC") as! FAQVC
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func connectWithUsPressed(_ sender: UIButton) {
        sender.backgroundColor = UIColor(r: 255, g: 182, b: 96 )
        UIView.animate(withDuration: 0.5, animations: { 
            sender.backgroundColor = UIColor.clear
        }) 
        let url = URL(string: "mailto:hello@shelfcosmetics.com")
        if url != nil && UIApplication.shared.canOpenURL(url!){
            UIApplication.shared.openURL(url!)
        }
    }
    
    @IBOutlet weak var faq: UIButton!
    @IBOutlet weak var connectWithUs: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBar()
        faq.backgroundColor = UIColor.clear
        connectWithUs.backgroundColor = UIColor.clear
    }
    
    func setupNavBar(){
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController!.navigationBar.isTranslucent = true
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController!.view.backgroundColor = UIColor.clear
    }

}
