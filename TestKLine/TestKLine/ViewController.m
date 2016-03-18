//
//  ViewController.m
//  TestKLine
//
//  Created by LRF on 15/9/15.
//  Copyright (c) 2015年 LRF. All rights reserved.
//

#import "ViewController.h"
#import "ImMarketPortraitVC.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)onClickKLine:(id)sender {
    ImMarketPortraitVC* klineContentVC = [[ImMarketPortraitVC alloc] initWithNibName:@"ImMarketPortraitVC" bundle:nil];
    
//    TradeCodeData* data = [self getTradeCodeDataWithSection:_controllerDropDownList.nSection withRow:_controllerDropDownList.nRow];
//    klineContentVC.tradeCodeData = data;
//    
    [self presentViewController:klineContentVC animated:YES completion:^()
     {
         
     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
