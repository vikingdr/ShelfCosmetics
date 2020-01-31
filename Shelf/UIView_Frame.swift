//
//  UIView_Frame.swift
//  qwix
//
//  Created by Nathan Konrad on 05.02.15.
//  Copyright (c) 2015 Shelf. All rights reserved.
//

import UIKit

extension UIView
{
    var top : CGFloat
        {
        get
        {
            return self.frame.minY
        }
        set
        {
            self.frame = CGRect(x: self.frame.minX,y: newValue,width: self.frame.width,height: self.frame.height)
        }
    }
    
    var bottom : CGFloat
        {
        get
        {
            return self.frame.maxY
        }
        set
        {
            self.frame = CGRect(x: self.frame.minX,y: newValue - self.frame.height,width: self.frame.width,height: self.frame.height)
        }
    }

    var left : CGFloat
        {
        get
        {
            return self.frame.minX
        }
        set
        {
            self.frame = CGRect(x: newValue,y: self.frame.minY,width: self.frame.width,height: self.frame.height)
        }
    }

    var right : CGFloat
        {
        get
        {
            return self.frame.maxX
        }
        set
        {
            self.frame = CGRect(x: newValue - self.frame.width, y: self.frame.minY, width: self.frame.width, height: self.frame.height)
        }
    }
    var width : CGFloat
        {
        get
        {
            return self.frame.width
        }
        set
        {
            self.frame = CGRect(x: self.frame.minX, y: self.frame.minY, width: newValue, height: self.frame.height)
        }
    }
    var height : CGFloat
        {
        get
        {
            return self.frame.height
        }
        set
        {
            self.frame = CGRect(x: self.frame.minX, y: self.frame.minY, width: self.frame.width, height: newValue)
        }
    }

    var centerY : CGFloat
        {
        get
        {
            return self.frame.minY + self.frame.height / 2
        }
        set
        {
            self.frame = CGRect(x: self.frame.minX,y: newValue - self.frame.height / 2,width: self.frame.width,height: self.frame.height)
        }
    }
    
    var centerX : CGFloat
        {
        get
        {
            return self.frame.minX + self.frame.width / 2
        }
        set
        {
            self.frame = CGRect(x: newValue - self.frame.width / 2,y: self.frame.minY,width: self.frame.width,height: self.frame.height)
        }
    }
    
}
