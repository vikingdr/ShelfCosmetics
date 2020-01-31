//
//  AptSteCell.swift
//  Shelf
//
//  Created by Nathan Konrad on 10/31/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import UIKit

let kGenericTwoFieldAddressCellIdentifier = "GenericTwoFieldAddressCell"

class GenericTwoFieldAddressCell: UITableViewCell {
    
    @IBOutlet weak var firstTextLabel: ShelfLabel!
    @IBOutlet weak var firstUserField: ShelfTextField!
    @IBOutlet weak var secondTextLabel: ShelfLabel!
    @IBOutlet weak var secondUserField: ShelfTextField!
    let kerningDefault = 0.6
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func setupCellType(_ type : TwoFieldType){
        
        if type == .aptSte {
            firstTextLabel.attributedText = setTitleAttributedString( "APT/STE")
            firstUserField.setPlaceHolder(kerningDefault, placeholderString: "Optional")
           
            
            secondTextLabel.attributedText = setTitleAttributedString( "C/O")
            
            secondUserField.setPlaceHolder(kerningDefault, placeholderString: "Optional")
        }
        else if type == .stateZip {
            
            firstTextLabel.attributedText = setTitleAttributedString( "STATE")
            firstUserField.setPlaceHolder(kerningDefault, placeholderString: "State")
            

            secondTextLabel.attributedText = setTitleAttributedString( "ZIP")
            secondUserField.setPlaceHolder(kerningDefault, placeholderString: "12345")
            secondUserField.keyboardType = .numberPad
        }
        else if type == .expirationCVC {
            firstUserField.setPlaceHolder(kerningDefault, placeholderString: "12/34")
            firstTextLabel.attributedText = setTitleAttributedString("EXPIRES")
            
            secondUserField.setPlaceHolder(kerningDefault, placeholderString: "123")
            secondTextLabel.attributedText = setTitleAttributedString("CVC")
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
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

enum TwoFieldType {
    case aptSte
    case stateZip
    case expirationCVC
}
