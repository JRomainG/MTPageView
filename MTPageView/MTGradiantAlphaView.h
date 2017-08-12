//
//  MTGradiantAlphaView.h
//  MTPageView
//
//  Created by Jean-Romain on 13/07/2017.
//  Copyright © 2017 JustKodding. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 * @typedef MTGradiantDirection
 * @brief A list of gradiant variations.
 * @constant MTGradiantDirectionLeftToRight Value used when the gradiant's alpha should be 1 on the left and 0 on the right.
 * @constant MTGradiantDirectionRightToLeft Value used when the gradiant's alpha should be 1 on the right and 0 on the left.
 */
typedef enum {
    MTGradiantDirectionLeftToRight,
    MTGradiantDirectionRightToLeft,
} MTGradiantDirection;

@interface MTGradiantAlphaView : UIView

@property (nonatomic) MTGradiantDirection gradiantDirection;

@end
