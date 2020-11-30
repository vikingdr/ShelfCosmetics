//
//  UIAppearance+Swift.m
//  Shelf
//
//  Created by Matthew James on 9/23/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIAppearance+Swift.h"
@import UIKit;
@implementation UIView (UIViewAppearance_Swift)
+ (instancetype)my_appearanceWhenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    return [self appearanceWhenContainedIn:containerClass, nil];
}
@end
@implementation UIBarItem (UIViewAppearance_Swift)
+ (instancetype)my_appearanceWhenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    return [self appearanceWhenContainedIn:containerClass, nil];
}
@end
