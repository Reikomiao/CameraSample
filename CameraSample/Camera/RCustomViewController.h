
//
//  Created by Reiko on 16/7/13.
//  Copyright © 2016年 Reiko. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CustomViewControllerDelegate <NSObject>
@optional
- (void)photoCapViewController:(UIViewController *)viewController didFinishDismissWithImage:(UIImage *)image;


@end
@interface RCustomViewController : UIViewController

@property(nonatomic, assign)id <CustomViewControllerDelegate> delegate;
@end
