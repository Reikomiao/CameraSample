//
//  CustomView.m
//  CameraSample
//
//  Created by 冯振玲 on 16/8/29.
//  Copyright © 2016年 Reiko. All rights reserved.
//

#import "CustomView.h"

@implementation CustomView


- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        UIView *subView= [[UIView alloc] initWithFrame:CGRectMake(100,100, 100, 50)];
        self.backgroundColor = [UIColor clearColor];
        subView.backgroundColor = [UIColor cyanColor];
        [self addSubview:subView];
    }
    return self;
}

@end
