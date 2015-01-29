//
//  BarCharView.m
//  Popularity
//
//  Created by Lane Phillips on 1/29/15.
//  Copyright (c) 2015 Milk LLC. All rights reserved.
//

#import "BarCharView.h"

@implementation BarCharView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.barWidth = 10;
    }
    return self;
}

- (void)prepareForInterfaceBuilder {
    NSMutableArray* random = [NSMutableArray array];
    for (NSInteger i = 0; i < 7 * 24; i++) {
        [random addObject:@(i + arc4random_uniform(6))];
    }
    self.bars = random;
}

- (void)drawRect:(CGRect)rect {
    CGFloat maxBar = 0;
    for (NSNumber* bar in self.bars) {
        maxBar = MAX(maxBar, bar.floatValue);
    }
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(ctx, 0, CGRectGetHeight(self.bounds));
    if (self.reverseDirection) {
        CGContextTranslateCTM(ctx, CGRectGetWidth(self.bounds), 0);
        CGContextScaleCTM(ctx, -1, 1);
    }
    CGContextScaleCTM(ctx, self.barWidth, -CGRectGetHeight(self.bounds) / maxBar);
    
    CGContextSetFillColorWithColor(ctx, [UIColor redColor].CGColor);
    CGFloat x = 0;
    for (NSNumber* bar in self.bars) {
        CGContextFillRect(ctx, CGRectMake(x, 0, 1, bar.floatValue));
        x += 1;
    }
}

@end
