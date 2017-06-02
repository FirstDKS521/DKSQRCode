//
//  RootViewController.m
//  DKSQRCode
//
//  Created by aDu on 2017/6/2.
//  Copyright © 2017年 DuKaiShun. All rights reserved.
//

#import "RootViewController.h"
#import "ScanViewController.h"
#import "HeadViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"二维码";
    self.view.backgroundColor = [UIColor whiteColor];
}

#pragma mark ========== 二维码扫描 ==========
- (IBAction)scanCode:(id)sender {
    ScanViewController *scanVC = [[ScanViewController alloc] init];
    [self.navigationController pushViewController:scanVC animated:YES];
}

#pragma mark ========== 二维码识别 ==========
- (IBAction)headCode:(id)sender {
    HeadViewController *headVC = [[HeadViewController alloc] init];
    [self.navigationController pushViewController:headVC animated:YES];
}

@end
