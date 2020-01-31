//
//  SelectBrandVC.swift
//  Shelf
//
//  Created by Nathan Konrad on 6/22/15.
//  Copyright (c) 2015 Shelf. All rights reserved.
//

import UIKit

class SelectBrandVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    
    var color : SColor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        setupTableView()
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: kSelectBrandCellIdentifier, bundle: nil), forCellReuseIdentifier: kSelectBrandCellIdentifier)
    }
}

extension SelectBrandVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BrandName.allValues.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kSelectBrandCellIdentifier, for: indexPath) as! SelectBrandCell
        
        setImageViewFromBrand(BrandName.allValues[indexPath.row].rawValue, imgViewBrand: cell.brandImageView)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        let storyboard: UIStoryboard = UIStoryboard(name: "CreateShelfie", bundle: nil)
        let vc: SelectColorVC = storyboard.instantiateViewController(withIdentifier: "SelectColorVC") as! SelectColorVC
        color?.brand = BrandName.allValues[indexPath.row].rawValue
        vc.color = color
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
