//
//  BarCharView.h
//  Popularity
//
//  Created by Lane Phillips on 1/29/15.
//  Copyright (c) 2015 Milk LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface BarChartView : UIView

@property (nonatomic) IBInspectable CGFloat barWidth;

// elements are assumed to implement floatValue
@property (nonatomic) NSArray* bars;

@property (nonatomic) NSArray* colorScale;

@property (nonatomic) IBInspectable BOOL reverseDirection;

@end
