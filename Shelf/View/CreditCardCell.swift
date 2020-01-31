//
//  CreditCardCell.swift
//  Shelf
//
//  Created by Nathan Konrad on 11/6/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import UIKit

class CreditCardCell: UICollectionViewCell {

    @IBOutlet weak var cardBackgroundClearView: UIView!
    @IBOutlet weak var expirationDate: UILabel!
    @IBOutlet weak var creditCardNumber: ShelfLabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cardBackgroundClearView.layer.shadowColor = UIColor.black.cgColor
        cardBackgroundClearView.layer.shadowOffset = CGSize(width: 0, height: 1)
        cardBackgroundClearView.layer.shadowOpacity = 1
        cardBackgroundClearView.layer.shadowRadius = 1
        cardBackgroundClearView.alpha = 0.1
        cardBackgroundClearView.layer.cornerRadius = 12
    }
    
    func setupCell( _ card : CreditCard){
        expirationDate.text = "Expires: " + card.expires
        creditCardNumber.text = "************\(String(card.creditCardNumber.characters.suffix(4)))"

    }

}
