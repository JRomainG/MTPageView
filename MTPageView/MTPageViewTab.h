//
//  MTPageViewTab.h
//  MTPageView
//
//  Created by Jean-Romain on 12/07/2017.
//  Copyright © 2017 JustKodding. All rights reserved.
//

#import "MTScrollBarManager.h"
#import <UIKit/UIKit.h>

@interface MTPageViewTab : UIView

@property (nonatomic) int index;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) MTScrollBarManager *scrollBarManager;

@end
