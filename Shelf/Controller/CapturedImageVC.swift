//
//  CapturedImageVC.swift
//  Shelf
//
//  Created by Nathan Konrad on 11/12/15.
//  Copyright © 2015 Shelf. All rights reserved.
//
// NOTE: DEPRECATED on 10/10/16

import UIKit

class CapturedImageVC: BaseVC {
    var capturedImage: UIImage!
    
    @IBOutlet var capturedImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        
        capturedImageView.image = capturedImage
    }

    @IBAction func nextButtonPressed(_ sender: AnyObject) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: SelectBrandVC = storyboard.instantiateViewController(withIdentifier: "SelectBrandVC") as! SelectBrandVC
        let color = SColor()
        color.image = capturedImage
        vc.color = color
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
