//
//  UIView+VeiwProparty.m
//  KINCT
//
//  Created by Ashish on 26/02/16.
//  Copyright © 2016 KINCT. All rights reserved.
//

#import "UIView+VeiwProparty.h"

@implementation UIView (VeiwProparty)
@dynamic borderColor,borderWidth,cornerRadius;
-(void)setBorderColor:(UIColor *)borderColor{
    [self.layer setBorderColor:borderColor.CGColor];
}

-(void)setBorderWidth:(CGFloat)borderWidth{
    [self.layer setBorderWidth:borderWidth];
}

-(void)setCornerRadius:(CGFloat)cornerRadius{
    [self.layer setCornerRadius:cornerRadius];
}
@end
