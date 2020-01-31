//
//  UIAppearance+Swift.h
//  Shelf
//
//  Created by Nathan Konrad on 9/23/16.
//  Copyright © 2016 Shelf. All rights reserved.
//
@import UIKit;
#ifndef UIAppearance_Swift_h
#define UIAppearance_Swift_h


#endif /* UIAppearance_Swift_h */
// UIAppearance+Swift.h
@interface UIView (UIViewAppearance_Swift)
// appearanceWhenContainedIn: is not available in Swift. This fixes that.
+ (instancetype)my_appearanceWhenContainedIn:(Class<UIAppearanceContainer>)containerClass;
@end

@interface UIBarItem (UIViewAppearance_Swift)
// appearanceWhenContainedIn: is not available in Swift. This fixes that.
+ (instancetype)my_appearanceWhenContainedIn:(Class<UIAppearanceContainer>)containerClass;
@end
