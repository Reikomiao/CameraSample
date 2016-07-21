//
//  WECustomViewController.h
//  WEFaceIdentificationSDKDemo
//
//  Created by 冯振玲 on 16/7/13.
//  Copyright © 2016年 Reiko. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CustomViewControllerDelegate <NSObject>
@optional
- (void)bringIDCardFrontImage:(UIImage *)frontImage;
- (void)bringIDCardBackImage:(UIImage *)backImage;
- (void)bringBankCardImage:(UIImage *)bankImage;

@end
@interface WECustomViewController : UIViewController
@property (nonatomic, strong)NSString *fromStr;
@property(nonatomic, assign)id <CustomViewControllerDelegate> delegate;
@end
