//
//  ViewController.m
//  CameraSample
//
//  Created by Reiko on 16/7/21.
//  Copyright © 2016年 Reiko. All rights reserved.
//

#import "ViewController.h"
#import "RCustomViewController.h"
#import "CustomView.h"
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
@interface ViewController ()<CustomViewControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *fileImage;
@property (nonatomic, strong) CustomView *customView;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.customView = [[CustomView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 400)];
    
    
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
