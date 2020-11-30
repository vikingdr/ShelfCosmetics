//
//  AddressCell.swift
//  Shelf
//
//  Created by Matthew James on 10/31/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import UIKit

let kGenericAddressCellIdentifier = "GenericAddressCell"

class GenericAddressCell: UITableViewCell {

    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var contentLabel: ShelfLabel!
    @IBOutlet weak var userContent: ShelfTextField!
 
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentLabel.text = ""
        userContent.text = ""
        separatorView.isHidden = false
        resignFirstResponder()
    }
    
    func setupCellType(_ type : OneFieldType){
        let kerningDefault = 0.6
        if type == .name {
            contentLabel.attributedText = setTitleAttributedString("NAME")
            userContent.setPlaceHolder(kerningDefault, placeholderString: "First and last name" )
        }
        else if type == .address {
            contentLabel.attributedText = setTitleAttributedString("ADDRESS")
            userContent.setPlaceHolder(kerningDefault, placeholderString: "123 Broadway" )
        }
        else if type == .city{
            contentLabel.attributedText = setTitleAttributedString("CITY")
            userContent.setPlaceHolder(kerningDefault, placeholderString: "City" )
        }
        else if type == .phone {
            contentLabel.attributedText = setTitleAttributedString("PHONE")
            userContent.setPlaceHolder(kerningDefault, placeholderString: "(310) 442 - 4884" )
           //userContent.placeholder = "(310) 442 - 4884"
            //userContent.setPlaceHolder(kerningDefault)
            userContent.keyboardType = .phonePad
        }
        else if type == .card {
            contentLabel.attributedText = setTitleAttributedString("CARD #")
            userContent.setPlaceHolder(kerningDefault, placeholderString: "1234 1234 1234 1234")
            userContent.keyboardType = .numberPad
        }
    }
    
    func setTitleAttributedString(_ str : String ) -> NSMutableAttributedString{
        let kerningDefaultTitle = 1.8
        let ph = NSMutableAttributedString(string: str)
        let color = UIColor(colorLiteralRed: 255, green: 255, blue: 255, alpha: 1)
        ph.addAttribute(NSForegroundColorAttributeName, value: color, range: NSMakeRange(0, ph.length))
        ph.addAttribute(NSKernAttributeName, value: kerningDefaultTitle, range:  NSMakeRange(0, ph.length))
        let font = UIFont(name: "Avenir-Black", size: 12)
        ph.addAttribute(NSFontAttributeName, value: font!, range: NSMakeRange(0, ph.length))
        return ph
    }
}

enum OneFieldType {
    case name
    case address
    case city
    case phone
    case card
}
