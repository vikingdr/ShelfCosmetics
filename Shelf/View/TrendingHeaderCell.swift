//
//  TrendingHeaderCell.swift
//  Shelf
//
//  Created by Nathan Konrad on 6/24/15.
//  Copyright (c) 2015 Shelf. All rights reserved.
//

import UIKit

class TrendingHeaderCell: UICollectionReusableView {
    
    @IBOutlet var btnList: UIButton!
    @IBOutlet var btnGrid: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let trendingTitle = NSMutableAttributedString(string: "Trending")
        trendingTitle.addAttribute(NSKernAttributeName, value: 3.0, range: NSMakeRange(0, trendingTitle.length))
        trendingTitle.addAttribute(NSForegroundColorAttributeName, value: UIColor.white, range: NSMakeRange(0, trendingTitle.length))
        lblTitle.attributedText = trendingTitle
    }
}
