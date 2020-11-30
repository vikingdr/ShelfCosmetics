//
//  SelectColorVC.swift
//  Shelf
//
//  Created by Matthew James on 6/22/15.
//  Copyright (c) 2015 Shelf. All rights reserved.
//

import UIKit

class SelectColorVC: BaseVC, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    @IBOutlet var findColorTitle: UILabel!
    var color : SColor?
    var brandColors : [SBrandColor] = []
    var filteredBrandColors : [SBrandColor] = []

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet var tableView: UITableView!
    
    fileprivate var tapGesture: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let selectColorPlaceholder = NSMutableAttributedString(string: "FIND YOUR COLOR")
        selectColorPlaceholder.addAttribute(NSKernAttributeName, value: 9, range: NSMakeRange(0, selectColorPlaceholder.length))
        findColorTitle.attributedText = selectColorPlaceholder
        
        let searchBarPlaceholder = NSMutableAttributedString(string: "TAP TO SEARCH " + color!.brand.uppercased())
        searchBarPlaceholder.addAttribute(NSKernAttributeName, value: 3, range: NSMakeRange(0, searchBarPlaceholder.length))
        searchBarPlaceholder.addAttribute(NSForegroundColorAttributeName, value: UIColor.white, range: NSMakeRange(0, searchBarPlaceholder.length))
        searchBarPlaceholder.addAttribute(NSFontAttributeName, value: UIFont(name: "Avenir-Book", size: 13)!, range: NSMakeRange(0, searchBarPlaceholder.length))
        searchTextField.attributedText = searchBarPlaceholder
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(SelectColorVC.viewTapped(_:)))
        
        tableView.separatorColor = UIColor.clear
        tableView.tableFooterView = UIView()
        reloadData()
    }
    
    func reloadData() {
        brandColors = []
        filteredBrandColors = []
        AppDelegate.showActivity()
        let query = PFQuery(className: "Brand_Color")
        query.whereKey("brand", equalTo: color!.brand)
        query.order(byAscending: "name")
        query.limit = 1000
        query.findObjectsInBackground { (objects, error) -> Void in
            if error == nil && objects != nil {
                for colorObject in objects! {
                    let brandColor = SBrandColor(data: colorObject)
                    self.brandColors.append(brandColor)
                }
                self.filteredBrandColors = self.brandColors
                DispatchQueue.main.async(execute: {
                    AppDelegate.hideActivity()
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storyboard: UIStoryboard = UIStoryboard(name: "CreateShelfie", bundle: nil)
        let vc: SaveColorVC = storyboard.instantiateViewController(withIdentifier: "SaveColorVC") as! SaveColorVC

        let filteredBrandColor = filteredBrandColors[indexPath.row]
        color?.colorName = filteredBrandColor.name
        color?.brand_color = filteredBrandColor.object
        vc.color = color
        self.navigationController?.pushViewController(vc, animated: true)

    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredBrandColors.count == 0 {
            let label = UILabel(frame: tableView.frame)
            label.text = "No Results"
            label.textAlignment = NSTextAlignment.center
            label.textColor = UIColor.white
            label.font = UIFont(name: "Avenir-Black", size: 15.0)
            label.center = tableView.center
            tableView.backgroundView = label
        }
        else {
            tableView.backgroundView = UIView()
        }
        
        return filteredBrandColors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectColorCell", for: indexPath) as! SelectColorCell
        
        let colorNameFont:UIFont = UIFont(name: "Avenir-Black", size: 15.0)!
        let colorCodeFont:UIFont = UIFont(name: "Avenir-Black", size: 12.0)!
        
        let filteredBrandColor = filteredBrandColors[indexPath.row]

        let colorName = NSMutableAttributedString(string: filteredBrandColor.name + "\n")
        colorName.addAttribute(NSFontAttributeName, value: colorNameFont, range: NSMakeRange(0, colorName.length))
        
        let colorCode = NSMutableAttributedString(string: filteredBrandColor.code)
        colorCode.addAttribute(NSFontAttributeName, value: colorCodeFont, range: NSMakeRange(0, colorCode.length))
        
        let titleString:NSMutableAttributedString = NSMutableAttributedString(attributedString: colorName)
        titleString.append(colorCode)
        
        cell.colorLabel.attributedText = titleString
      
        cell.brandColor = filteredBrandColor
        
        return cell
    }
    
    //MARK:-UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.attributedText?.string == "TAP TO SEARCH " + color!.brand.uppercased() {
            textField.attributedText = nil
            textField.text = ""
        }
        view.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func textFieldValueDidChange(_ sender: AnyObject) {
        print("textFieldValueDidChange")
        if searchTextField.text!.characters.count == 0 {
            filteredBrandColors = brandColors
        }
        else if searchTextField.text!.characters.count > 0 {
			// removed by KMHK
//            filteredBrandColors = filter(brandColors) { $0.name.lowercased().range(of: self.searchTextField.text!.lowercased(), options: NSString.CompareOptions.caseInsensitive, range: Range<String.Index>($0.name.characters.indices), locale: nil) != nil }
        }
        
        tableView.reloadData()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == "" {
            let searchBarPlaceholder = NSMutableAttributedString(string: "TAP TO SEARCH " + color!.brand.uppercased())
            searchBarPlaceholder.addAttribute(NSKernAttributeName, value: 3, range: NSMakeRange(0, searchBarPlaceholder.length))
            searchBarPlaceholder.addAttribute(NSForegroundColorAttributeName, value: UIColor.white, range: NSMakeRange(0, searchBarPlaceholder.length))
            searchBarPlaceholder.addAttribute(NSFontAttributeName, value: UIFont(name: "Avenir-Book", size: 14)!, range: NSMakeRange(0, searchBarPlaceholder.length))
            searchTextField.attributedText = searchBarPlaceholder
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        viewTapped(tapGesture)
        return true
    }
    
    func filter<SBrandColor>(_ source: [SBrandColor], predicate:(SBrandColor) -> Bool) -> [SBrandColor] {
        var result = [SBrandColor]()
        for brandColor in source {
            if predicate(brandColor) {
                result.append(brandColor)
            }
        }
        return result
    }
    
    //MARK:-Helper functions
    func viewTapped(_ gesture: UIGestureRecognizer) {
        view.removeGestureRecognizer(tapGesture)
        searchTextField.resignFirstResponder()
    }

    
}
