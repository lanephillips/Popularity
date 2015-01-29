//
//  BarCharView.h
//  Popularity
//
//  Created by Lane Phillips on 1/29/15.
//  Copyright (c) 2015 Milk LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface BarCharView : UIView

@property (nonatomic) IBInspectable CGFloat barWidth;

@property (nonatomic) NSArray* bars;
// maps bar values to [0, 1]
@property (nonatomic,copy) CGFloat (^transferFunction)(CGFloat x);

@property (nonatomic) NSArray* colorScale;

@property (nonatomic) IBInspectable BOOL reverseDirection;

@end
