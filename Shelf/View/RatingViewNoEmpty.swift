//
//  RatingViewNoEmpty.swift
//  Shelf
//
//  Created by Nathan Konrad on 10/10/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import UIKit

class RatingViewNoEmpty: UIView {
    internal fileprivate(set) var ratingSelected = false
    var stars : [UIImageView] = []
    var returnFunc : ((Int)->())?
    var allowTouches = false
    var rating : Int  = 0 {
        didSet {
            for index in 1...starsCount {
                stars[index-1].isHighlighted = (index <= rating)
            }
        }
    }
    
    // MARK: - initialize
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    // Create 5 stars imageViews
    func initialize() {
        let width = frame.width/CGFloat(starsCount)
        
        for _ in 0 ..< starsCount {
            let starImageView = UIImageView(image: UIImage(named: "star"), highlightedImage: UIImage(named: "star_selected"))
            starImageView.frame = CGRect(x: 0, y: 0, width: width, height: frame.height)
            starImageView.contentMode = .scaleAspectFit
            stars.append(starImageView)
            self.addSubview(starImageView)
        }
        rating = 0
    }
    
    override func layoutSubviews() {
        let starWidth = self.width / CGFloat(starsCount)
        for i in 0 ..< starsCount {
            let starImagView = stars[i]
            starImagView.centerY = self.height / 2
            starImagView.centerX = CGFloat(i) * starWidth  + starWidth / 2
        }
    }
    
    // MARK: - touches methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touch(touches, withEvent: event!)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touch(touches, withEvent: event!)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touch(touches, withEvent: event!)
    }
    
    func touch(_ touches: Set<NSObject>, withEvent event: UIEvent) {
        if allowTouches == true {
            ratingSelected = true
            let touch = touches.first as! UITouch
            let point = touch.location(in: self)
            let starWidth = self.width / CGFloat(starsCount)
            self.rating = Int(point.x / starWidth) + 1
            if returnFunc != nil {
                returnFunc!(rating)
            }
        }
        
    }
}
