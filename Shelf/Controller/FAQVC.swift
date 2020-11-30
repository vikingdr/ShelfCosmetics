//
//  FAQVC.swift
//  Shelf
//
//  Created by Matthew James on 11/9/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import UIKit

class FAQVC: BaseVC {
    @IBOutlet weak var tableView: UITableView!

    
    override func viewDidLoad() {
        //super.viewDidLoad()
        setupTableView()
        setupBackButton()
        setupNavigationBar()
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        title = "FAQ"
    }
    
    func setupTableView(){
        tableView.register(UINib(nibName: "FAQCell", bundle: nil),forCellReuseIdentifier: "FAQCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 212
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 21, left: 0, bottom: 114, right: 0)
        
    }
}


extension FAQVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 12
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FAQCell") as! FAQCell
        cell.titleLabel.text = NSLocalizedString("\(indexPath.row)FAQTitle", comment: "")
        cell.contentLabel.text = NSLocalizedString("\(indexPath.row)FAQContent", comment: "")
        cell.selectionStyle = .none
        return cell
    }
}
