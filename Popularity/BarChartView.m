//
//  BarCharView.m
//  Popularity
//
//  Created by Lane Phillips on 1/29/15.
//  Copyright (c) 2015 Milk LLC. All rights reserved.
//

#import "BarChartView.h"

@implementation BarChartView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.barWidth = 10;
    
    self.colorScale = [[@[// Name: CB_div_RdBu_11
                          // This color palette was developed by Cynthia Brewer
                          // http://colorbrewer2.org/?type=diverging&scheme=RdBu&n=11
                          [UIColor colorWithRed:103/255.0f green:  0/255.0f blue: 31/255.0f alpha:1.0f],
                          [UIColor colorWithRed:178/255.0f green: 24/255.0f blue: 43/255.0f alpha:1.0f],
                          [UIColor colorWithRed:214/255.0f green: 96/255.0f blue: 77/255.0f alpha:1.0f],
                          [UIColor colorWithRed:244/255.0f green:165/255.0f blue:130/255.0f alpha:1.0f],
                          [UIColor colorWithRed:253/255.0f green:219/255.0f blue:199/255.0f alpha:1.0f],
                          [UIColor colorWithRed:247/255.0f green:247/255.0f blue:247/255.0f alpha:1.0f],
                          [UIColor colorWithRed:209/255.0f green:229/255.0f blue:240/255.0f alpha:1.0f],
                          [UIColor colorWithRed:146/255.0f green:197/255.0f blue:222/255.0f alpha:1.0f],
                          [UIColor colorWithRed: 67/255.0f green:147/255.0f blue:195/255.0f alpha:1.0f],
                          [UIColor colorWithRed: 33/255.0f green:102/255.0f blue:172/255.0f alpha:1.0f],
                          [UIColor colorWithRed:  5/255.0f green: 48/255.0f blue: 97/255.0f alpha:1.0f]
                          ] reverseObjectEnumerator] allObjects];
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
    // flip y
    CGContextTranslateCTM(ctx, 0, CGRectGetHeight(self.bounds));
    CGContextScaleCTM(ctx, 1, -1);
    if (self.reverseDirection) {    // flip x
        CGContextTranslateCTM(ctx, CGRectGetWidth(self.bounds), 0);
        CGContextScaleCTM(ctx, -1, 1);
    }
    
    // tallest bar will be drawn as 1 x maxBar and will render as barWidth x widget height
    CGContextScaleCTM(ctx, self.barWidth, CGRectGetHeight(self.bounds) / maxBar);
    
    CGFloat x = 0;
    for (NSNumber* bar in self.bars) {
        CGFloat intensity = bar.floatValue / maxBar;
        if (self.transferFunction) {
            intensity = self.transferFunction(bar.floatValue);
        }
        
        // TODO: or maybe I want a gradient that is the same for every bar
        UIColor* c = [self interpolateColor:intensity];
        
        CGContextSetFillColorWithColor(ctx, c.CGColor);
        CGContextFillRect(ctx, CGRectMake(x, 0, 1.1, bar.floatValue));  // slightly wide so there are no gaps
        
        x += 1;
    }
}

- (UIColor*)nearestColor:(CGFloat)c {
    if (self.colorScale.count == 0) {
        return [UIColor greenColor];
    }
    if (self.colorScale.count == 1) {
        return self.colorScale.lastObject;
    }
    
    c *= self.colorScale.count - 1; // map [0, 1] to [0, n colors - 1]
    
    NSInteger ilo = floor(c);
    ilo = MAX(0, MIN(ilo, self.colorScale.count - 2));
    
    CGFloat frac1 = c - ilo;
    CGFloat frac0 = ilo + 1 - c;
    
    if (frac0 > frac1) {
        return self.colorScale[ilo];
    } else {
        return self.colorScale[ilo + 1];
    }
}

- (UIColor*)interpolateColor:(CGFloat)c {
    if (self.colorScale.count == 0) {
        return [UIColor redColor];
    }
    if (self.colorScale.count == 1) {
        return self.colorScale.lastObject;
    }
    
    c *= self.colorScale.count - 1; // map [0, 1] to [0, n colors - 1]
    
    // find nearest colors
    NSInteger ilo = floor(c);
    ilo = MAX(0, MIN(ilo, self.colorScale.count - 2));
    
    CGFloat r0, b0, g0, a0, r1, b1, g1, a1;
    [(UIColor*)self.colorScale[ilo + 0] getRed:&r0 green:&g0 blue:&b0 alpha:&a0];
    [(UIColor*)self.colorScale[ilo + 1] getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
    
    // interpolate
    CGFloat frac1 = c - ilo;
    frac1 = MAX(0, MIN(frac1, 1));
    CGFloat frac0 = 1 - frac1;
    
    return [UIColor colorWithRed:frac0 * r0 + frac1 * r1
                           green:frac0 * g0 + frac1 * g1
                            blue:frac0 * b0 + frac1 * b1
                           alpha:frac0 * a0 + frac1 * a1];
}

@end
