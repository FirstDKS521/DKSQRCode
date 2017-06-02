//
//  HeadViewController.m
//  DKSQRCode
//
//  Created by aDu on 2017/6/2.
//  Copyright © 2017年 DuKaiShun. All rights reserved.
//

#import "HeadViewController.h"

static NSString* const kTouchJavaScriptString=
@"document.ontouchstart=function(event){\
x=event.targetTouches[0].clientX;\
y=event.targetTouches[0].clientY;\
document.location=\"myweb:touch:start:\"+x+\":\"+y;};\
document.ontouchmove=function(event){\
x=event.targetTouches[0].clientX;\
y=event.targetTouches[0].clientY;\
document.location=\"myweb:touch:move:\"+x+\":\"+y;};\
document.ontouchcancel=function(event){\
document.location=\"myweb:touch:cancel\";};\
document.ontouchend=function(event){\
document.location=\"myweb:touch:end\";};";

@interface HeadViewController ()<UIWebViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NSURLRequest *request;

@end

@implementation HeadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"识别二维码";
    self.view.backgroundColor = [UIColor whiteColor];
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    [self loadHTML:@"http://r.xiumi.us/stage/v5/2Aagl/41853179"];
}

//加载URL
- (void)loadHTML:(NSString *)htmlString
{
    NSURL *url = [NSURL URLWithString:htmlString];
    self.request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5.0];
    [self.webView loadRequest:self.request];
}

#pragma mark - UIWebViewDelegate

//设置webview的title为导航栏的title
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    UILongPressGestureRecognizer *longPressed = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    longPressed.delegate = self;
    [self.webView addGestureRecognizer:longPressed];
}

// add by zcj 长按识别图中二维码
- (void)longPressed:(UILongPressGestureRecognizer*)recognizer
{
    if (recognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    CGPoint touchPoint = [recognizer locationInView:self.webView];
    // 获取手势所在图片的URL，js中图片的地址是用src引用的
    NSString *imgURL = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", touchPoint.x, touchPoint.y];
    NSString *urlToSave = [self.webView stringByEvaluatingJavaScriptFromString:imgURL];
    
    if (urlToSave.length == 0) {
        return;
    }
    
    [self showImageOptionsWithUrl:urlToSave];
}

- (void)showImageOptionsWithUrl:(NSString *)imgURL
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    //根据URL生成图片
    NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgURL]];
    UIImage* image = [UIImage imageWithData:data];
    
    CIImage *ciImage = [[CIImage alloc] initWithCGImage:image.CGImage options:nil];
    CIContext *context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : @(NO)}];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];
    NSArray *features = [detector featuresInImage:ciImage];
    NSString *scannedResult = nil;
    for (CIQRCodeFeature *feature in features) {
        scannedResult = feature.messageString;
    }
    
    // 识别图中二维码
    UIAlertAction *judgeCode = [UIAlertAction actionWithTitle:@"识别图中二维码" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:scannedResult]]){
            //如果是URL，打开
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:scannedResult]];
        } else {
            NSLog(@"无法识别");
        }
    }];
    
    // 保存图片到手机
    UIAlertAction *saveImage = [UIAlertAction actionWithTitle:@"保存图片到手机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
    }];
    
    // 取消
    UIAlertAction *cancell = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    if (features.count >= 1) {
        [alertController addAction:judgeCode];
    }
    
    [alertController addAction:saveImage];
    [alertController addAction:cancell];
    [self presentViewController:alertController animated:YES completion:nil];
    
}
// 功能：显示图片保存结果
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo
{
    if (error){
        NSLog(@"图片保存失败");
    } else {
        NSLog(@"图片保存成功");
    }
}

@end
