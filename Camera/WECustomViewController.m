//
//  CustomViewController.m
//  LivenessDemo
//
//  Created by 冯振玲 on 16/3/25.
//  Copyright © 2016年 冯振玲. All rights reserved.
//

#import "WECustomViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIImage+rotation.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight  [UIScreen mainScreen].bounds.size.height



@interface WECustomViewController ()<UIGestureRecognizerDelegate>

@property (strong, nonatomic)  UIImageView *apertureImageView;
@property (strong, nonatomic)  UIView *backView;
@property (strong, nonatomic)  UILabel *hintLable;

// AVCaptureSession对象来执行输入设备和输出设备之间的数据传递
@property (nonatomic, strong) AVCaptureSession* session;

// 输入设备
@property (nonatomic, strong) AVCaptureDeviceInput* videoInput;
// 照片输出流
@property (nonatomic, strong) AVCaptureStillImageOutput* stillImageOutput;

//  预览图层
@property (nonatomic, strong) AVCaptureVideoPreviewLayer* previewLayer;

/**
 *  记录开始的缩放比例
 */
@property(nonatomic,assign)CGFloat beginGestureScale;
/**
 * 最后的缩放比例
 */
@property(nonatomic,assign)CGFloat effectiveScale;
@end

@implementation WECustomViewController
- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    if (self.session) {
        
        [self.session startRunning];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSubViews];
    self.fromStr = @"IdCardFront";
        self.effectiveScale = self.beginGestureScale = 1.0f;
    self.hintLable.transform = CGAffineTransformMakeRotation(M_PI/2);
    if ([self.fromStr isEqualToString:@"IdCardFront"]) {
        self.apertureImageView.image = [UIImage imageNamed:@"faceidcard"];
        self.hintLable.text = @"请拍摄身份证正面，保持文字清晰";
    }else if([self.fromStr isEqualToString:@"IdCardBack"]){
        self.apertureImageView.image = [UIImage imageNamed:@"backidcard"];
        self.hintLable.text = @"请拍摄身份证反面，保持文字清晰";
        
    }else if([self.fromStr isEqualToString:@"BankCard"]){
        self.hintLable.text = @"请拍摄银行卡正面，保持数字清晰";
        
    }
    [self initAVCaptureSession];
    [self setUpGesture];
    
}
- (void)addSubViews{
    UIView *backView = [[UIView alloc] init];
    backView.translatesAutoresizingMaskIntoConstraints = NO;
    self.backView = backView;
    [self.view addSubview:backView];
   NSLayoutConstraint *leftBackView =  [NSLayoutConstraint constraintWithItem:backView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
   NSLayoutConstraint *rightBackView =  [NSLayoutConstraint constraintWithItem:backView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0];
   NSLayoutConstraint *topBackView =  [NSLayoutConstraint constraintWithItem:backView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0];
   NSLayoutConstraint *bottomBackView =  [NSLayoutConstraint constraintWithItem:backView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [self.view addConstraints:@[leftBackView,rightBackView,topBackView,bottomBackView]];
// 拍摄区域
    self.apertureImageView = [[UIImageView alloc] init];
    [backView addSubview:self.apertureImageView];
    self.apertureImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [backView addConstraint:[NSLayoutConstraint constraintWithItem:self.apertureImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:backView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [backView addConstraint:[NSLayoutConstraint constraintWithItem:self.apertureImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:backView attribute:NSLayoutAttributeCenterY multiplier:1 constant:-20]];
    [backView addConstraint:[NSLayoutConstraint constraintWithItem:self.apertureImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:backView attribute:NSLayoutAttributeHeight multiplier:0.75 constant:0]];
    [backView addConstraint:[NSLayoutConstraint constraintWithItem:self.apertureImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:backView attribute:NSLayoutAttributeWidth multiplier:0.8 constant:0]];

    
    // 上面的阴影部分
    UIImageView *topImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shadow"]];
    topImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [backView addSubview:topImageView];
    [backView addConstraint:[NSLayoutConstraint constraintWithItem:topImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:backView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [backView addConstraint:[NSLayoutConstraint constraintWithItem:topImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:backView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [backView addConstraint:[NSLayoutConstraint constraintWithItem:topImageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:backView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    [backView addConstraint:[NSLayoutConstraint constraintWithItem:topImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.apertureImageView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    // 右边的阴影部分
    UIImageView *leftImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shadow"]];
    leftImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [backView addSubview:leftImageView];
    [backView addConstraint:[NSLayoutConstraint constraintWithItem:leftImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:backView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [backView addConstraint:[NSLayoutConstraint constraintWithItem:leftImageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.apertureImageView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [backView addConstraint:[NSLayoutConstraint constraintWithItem:leftImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:topImageView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [backView addConstraint:[NSLayoutConstraint constraintWithItem:leftImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.apertureImageView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    // 左边的阴影部分
    UIImageView *rightImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shadow"]];
    rightImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [backView addSubview:rightImageView];
    [backView addConstraint:[NSLayoutConstraint constraintWithItem:rightImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:topImageView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [backView addConstraint:[NSLayoutConstraint constraintWithItem:rightImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.apertureImageView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    [backView addConstraint:[NSLayoutConstraint constraintWithItem:rightImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.apertureImageView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [backView addConstraint:[NSLayoutConstraint constraintWithItem:rightImageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:backView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    // 下面的阴影区域
    UIImageView *bottomImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shadow"]];
    bottomImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [backView addSubview:bottomImageView];
    [backView addConstraint:[NSLayoutConstraint constraintWithItem:bottomImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:rightImageView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [backView addConstraint:[NSLayoutConstraint constraintWithItem:bottomImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:backView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [backView addConstraint:[NSLayoutConstraint constraintWithItem:bottomImageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:backView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    [backView addConstraint:[NSLayoutConstraint constraintWithItem:bottomImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:20]];
    // 提示文字
    UILabel *hintLable = [[UILabel alloc] init];
    hintLable.textAlignment = NSTextAlignmentCenter;
    self.hintLable = hintLable;
    hintLable.translatesAutoresizingMaskIntoConstraints = NO;
    [backView addSubview:hintLable];
    [backView addConstraint:[NSLayoutConstraint constraintWithItem:hintLable attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:leftImageView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [backView addConstraint:[NSLayoutConstraint constraintWithItem:hintLable attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:leftImageView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [backView addConstraint:[NSLayoutConstraint constraintWithItem:hintLable attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:leftImageView attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    [backView addConstraint:[NSLayoutConstraint constraintWithItem:hintLable attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:leftImageView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    // 照相区域
    UIView *takePhoneView = [[UIView alloc] init];
    takePhoneView.backgroundColor = [UIColor blackColor];
    takePhoneView.translatesAutoresizingMaskIntoConstraints = NO;
    [backView addSubview:takePhoneView];
    [backView addConstraint:[NSLayoutConstraint constraintWithItem:takePhoneView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:bottomImageView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [backView addConstraint:[NSLayoutConstraint constraintWithItem:takePhoneView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:backView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [backView addConstraint:[NSLayoutConstraint constraintWithItem:takePhoneView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:backView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    [backView addConstraint:[NSLayoutConstraint constraintWithItem:takePhoneView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:backView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
   
    
// 照相按钮
    UIButton *takePhoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [takePhoneButton setImage:[UIImage imageNamed:@"photo"] forState:UIControlStateNormal];
    [takePhoneButton addTarget:self action:@selector(actionTakePhone:) forControlEvents:UIControlEventTouchUpInside];
    takePhoneButton.translatesAutoresizingMaskIntoConstraints = NO;
    [takePhoneView addSubview:takePhoneButton];
    [takePhoneView addConstraint:[NSLayoutConstraint constraintWithItem:takePhoneButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:takePhoneView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [takePhoneView addConstraint:[NSLayoutConstraint constraintWithItem:takePhoneButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:takePhoneView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [takePhoneView addConstraint:[NSLayoutConstraint constraintWithItem:takePhoneButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:takePhoneView attribute:NSLayoutAttributeHeight multiplier:0.8 constant:0]];
    [takePhoneView addConstraint:[NSLayoutConstraint constraintWithItem:takePhoneButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:takePhoneButton attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    // 取消按钮
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(actionCancelButton:) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    [takePhoneView addSubview:cancelButton];
    [takePhoneView addConstraint:[NSLayoutConstraint constraintWithItem:cancelButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:takePhoneView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [takePhoneView addConstraint:[NSLayoutConstraint constraintWithItem:cancelButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:takePhoneView attribute:NSLayoutAttributeLeft multiplier:1 constant:10]];
    [takePhoneView addConstraint:[NSLayoutConstraint constraintWithItem:cancelButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:takePhoneButton attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [takePhoneView addConstraint:[NSLayoutConstraint constraintWithItem:cancelButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:50]];

   
}
- (void)initAVCaptureSession{
    
    self.session = [[AVCaptureSession alloc] init];
    
    NSError *error;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //更改这个设置的时候必须先锁定设备，修改完后再解锁，否则崩溃
    [device lockForConfiguration:nil];
    //设置闪光灯为自动
    [device setFlashMode:AVCaptureFlashModeAuto];
    [device unlockForConfiguration];
    
    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    //输出设置。AVVideoCodecJPEG   输出jpeg格式图片
    NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    [self.stillImageOutput setOutputSettings:outputSettings];
    
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
    if ([self.session canAddOutput:self.stillImageOutput]) {
        [self.session addOutput:self.stillImageOutput];
    }
    
    //初始化预览图层
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    self.previewLayer.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight * 0.875);
    self.backView.layer.masksToBounds = YES;
    [self.view.layer addSublayer:self.previewLayer];
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
    [self.view bringSubviewToFront:self.backView];;
}
- (void)actionTakePhone:(UIButton *)sender {
    
    AVCaptureConnection *stillImageConnection = [self.stillImageOutput        connectionWithMediaType:AVMediaTypeVideo];
    UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
    AVCaptureVideoOrientation avcaptureOrientation = [self avOrientationForDeviceOrientation:curDeviceOrientation];
    [stillImageConnection setVideoOrientation:avcaptureOrientation];
    [stillImageConnection setVideoScaleAndCropFactor:self.effectiveScale];
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (!error) {
            NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            //原始的图片
            UIImage *originalImage = [UIImage imageWithData:jpegData];
            // 截取的图片
            CGSize imagesize = originalImage.size;
            imagesize.height =imagesize.height*1024/imagesize.width;
            imagesize.width =1024;
            UIImage *screenshotImage = [UIImage imageWithImage:originalImage scaledToSize:imagesize];
            // 旋转的图片
            //        UIImage *rotationImage = [UIImage image:originalImage rotation:UIImageOrientationUp];
            if ([self.fromStr isEqualToString:@"IdCardFront"]) {
                if(_delegate && [_delegate respondsToSelector:@selector(bringIDCardFrontImage:)]){
                    
                    [_delegate bringIDCardFrontImage:screenshotImage];
                }
            }else if ([self.fromStr isEqualToString:@"IdCardBack"]) {
                if(_delegate && [_delegate respondsToSelector:@selector(bringIDCardBackImage:)]){
                    [_delegate bringIDCardBackImage:screenshotImage];
                    
                }
            }else{
                if(_delegate && [_delegate respondsToSelector:@selector(bringBankCardImage:)]){
                    [_delegate bringBankCardImage:screenshotImage];
                    
                }
            }
            
            
//            CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault,imageDataSampleBuffer,kCMAttachmentMode_ShouldPropagate);
//            
//            ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
//            if (author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied){
//                //无权限
//                return ;
//            }
//            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//            [library writeImageDataToSavedPhotosAlbum:jpegData metadata:(__bridge id)attachments completionBlock:^(NSURL *assetURL, NSError *error) {
//                
//            }];
        }else{
            NSLog(@"闪退");
        }
    }];
    [_session stopRunning];
    sleep(1);
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
    AVCaptureVideoOrientation result = (AVCaptureVideoOrientation)deviceOrientation;
    if ( deviceOrientation == UIDeviceOrientationLandscapeLeft )
        result = AVCaptureVideoOrientationLandscapeRight;
    else if ( deviceOrientation == UIDeviceOrientationLandscapeRight )
        result = AVCaptureVideoOrientationLandscapeLeft;
    return result;
}
- (void)actionCancelButton:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
#pragma 创建手势
- (void)setUpGesture{
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    pinch.delegate = self;
    [self.backView addGestureRecognizer:pinch];
}
#pragma mark gestureRecognizer delegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ( [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] ) {
        self.beginGestureScale = self.effectiveScale;
    }
    return YES;
}
//缩放手势 用于调整焦距
- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer{
    
    BOOL allTouchesAreOnThePreviewLayer = YES;
    NSUInteger numTouches = [recognizer numberOfTouches], i;
    for ( i = 0; i < numTouches; ++i ) {
        CGPoint location = [recognizer locationOfTouch:i inView:self.backView];
        CGPoint convertedLocation = [self.previewLayer convertPoint:location fromLayer:self.previewLayer.superlayer];
        if ( ! [self.previewLayer containsPoint:convertedLocation] ) {
            allTouchesAreOnThePreviewLayer = NO;
            break;
        }
    }
    
    if ( allTouchesAreOnThePreviewLayer ) {
        
        
        self.effectiveScale = self.beginGestureScale * recognizer.scale;
        if (self.effectiveScale < 1.0){
            self.effectiveScale = 1.0;
        }
        
        NSLog(@"%f-------------->%f------------recognizerScale%f",self.effectiveScale,self.beginGestureScale,recognizer.scale);
        
        CGFloat maxScaleAndCropFactor = [[self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo] videoMaxScaleAndCropFactor];
        
        NSLog(@"%f",maxScaleAndCropFactor);
        if (self.effectiveScale > maxScaleAndCropFactor)
            self.effectiveScale = maxScaleAndCropFactor;
        
        [CATransaction begin];
        [CATransaction setAnimationDuration:.025];
        [self.previewLayer setAffineTransform:CGAffineTransformMakeScale(self.effectiveScale, self.effectiveScale)];
        [CATransaction commit];
        
    }
    
}


- (void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:YES];
    
    if (self.session) {
        
        [self.session stopRunning];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end