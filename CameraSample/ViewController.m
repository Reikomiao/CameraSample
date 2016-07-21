//
//  ViewController.m
//  CameraSample
//
//  Created by Reiko on 16/7/21.
//  Copyright © 2016年 Reiko. All rights reserved.
//

#import "ViewController.h"
#import "RCustomViewController.h"

@interface ViewController ()<CustomViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *fileImage;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)actionShot:(UIButton *)sender {
    
#if TARGET_IPHONE_SIMULATOR
    NSLog(@"居然用模拟器运行,你给我支持一个相机试试");
#else
    RCustomViewController *customVC = [[RCustomViewController alloc] init];
    customVC.delegate = self;
    [self presentViewController:customVC animated:YES completion:nil];
#endif

}
// 代理方法
-(void)photoCapViewController:(UIViewController *)viewController didFinishDismissWithImage:(UIImage *)image{
    self.fileImage.image = image;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
