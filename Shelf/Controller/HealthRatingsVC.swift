//
//  FAQVC.swift
//  Shelf
//
//  Created by Nathan Konrad on 11/8/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import UIKit

class HealthRatingsVC: BaseVC {

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
       // super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        setupBackButton()
    }

    func setupTableView(){
        tableView.estimatedRowHeight = 144
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "HealthRatingFreeSystemCell", bundle: nil), forCellReuseIdentifier: "HealthRatingFreeSystemCell")
        tableView.register(UINib(nibName: "HealthRatingsInfoCell", bundle: nil), forCellReuseIdentifier: "HealthRatingsInfoCell")
        tableView.register(UINib(nibName: "ChemicalImageCell", bundle: nil), forCellReuseIdentifier: "ChemicalImageCell")
        tableView.register(UINib(nibName: "ChemicalInfoCell", bundle: nil), forCellReuseIdentifier: "ChemicalInfoCell")
        tableView.register(UINib(nibName: "SourcesCell", bundle: nil), forCellReuseIdentifier: "SourcesCell")
        tableView.register(UINib(nibName: "SourcesInfoCell", bundle: nil), forCellReuseIdentifier: "SourcesInfoCell")
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0)
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        title = "Health Rating Info"
    }
    
    
}

extension HealthRatingsVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 22
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HealthRatingFreeSystemCell") as! HealthRatingFreeSystemCell
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            return cell
        }
        else if indexPath.row < 6 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HealthRatingsInfoCell") as! HealthRatingsInfoCell
            let title = NSLocalizedString("\(indexPath.row + 2)FreeNailPolish", comment: "")
            let content = NSLocalizedString("\(indexPath.row + 2)FreeNailPolishContent", comment: "")
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 0
            paragraphStyle.alignment = NSTextAlignment.center

            let attrString = NSMutableAttributedString(string: content)
            attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
            let font = UIFont(name: "Avenir-Black", size: 14)
            attrString.addAttribute(NSFontAttributeName, value: font!, range: NSMakeRange(0, attrString.length))
            attrString.addAttribute(NSKernAttributeName, value: 0.4, range: NSMakeRange(0, attrString.length))
            

            cell.titleCell.text = title
            cell.labelCell.attributedText = attrString
            
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            return cell
        }
        else if indexPath.row == 6 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChemicalImageCell") as! ChemicalImageCell
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            return cell
        }
        else if indexPath.row < 15 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChemicalInfoCell") as! ChemicalInfoCell
            let content = NSLocalizedString("\(indexPath.row)ChemicalContent", comment: "")
            let title = NSLocalizedString("\(indexPath.row)ChemicalTitle", comment: "")
            
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 7
            paragraphStyle.alignment = NSTextAlignment.center
            cell.chemicalDescription.text = content
            let attrString = NSMutableAttributedString(attributedString: cell.chemicalDescription.attributedText!)
            attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
            let font = UIFont(name: "Avenir-Black", size: 13.5)
            attrString.addAttribute(NSFontAttributeName, value: font!, range: NSMakeRange(0, attrString.length))
            attrString.addAttribute(NSKernAttributeName, value: 0.4, range: NSMakeRange(0, attrString.length))
            
            
            cell.chemicalDescription.attributedText = attrString
            cell.chemicalTitle.text = title
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            return cell
        }
        else if indexPath.row == 15 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SourcesCell") as! SourcesCell
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            return cell
        }
        else if indexPath.row >= 16 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SourcesInfoCell") as! SourcesInfoCell
            let content = NSLocalizedString("\(indexPath.row)SourceLink", comment: "")
            let title = NSLocalizedString("\(indexPath.row)SourceTitle", comment: "")

            
            cell.emailOfSource.text = content
            cell.nameOfSource.text = title
            
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            return cell
        }
        else{
             return UITableViewCell()
        }
        
    }
}
