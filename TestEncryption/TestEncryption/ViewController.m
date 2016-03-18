//
//  ViewController.m
//  TestEncryption
//
//  Created by LRF on 16/1/22.
//  Copyright © 2016年 LRF. All rights reserved.
//

#import "ViewController.h"
#import "AESCrypt.h"
#import "MD5.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *data;
@property (weak, nonatomic) IBOutlet UILabel *md5Result;

@property (weak, nonatomic) IBOutlet UILabel *AESEncodeResult;
@property (weak, nonatomic) IBOutlet UILabel *AESDecodeResult;
@property (weak, nonatomic) IBOutlet UILabel *RSCEncodeResult;
@property (weak, nonatomic) IBOutlet UILabel *RSCDecodeResult;
@property (weak, nonatomic) IBOutlet UILabel *Base64EncodeResult;
@property (weak, nonatomic) IBOutlet UILabel *Base64DecodeResult;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
- (IBAction)onMD5:(id)sender {
    NSString *str = [MD5 md5:self.data.text];
    NSLog(@"str =%@",str);
    [self.md5Result setText:str];
}
- (IBAction)onAESEncode:(id)sender {
    
    [self.AESEncodeResult setText:[AESCrypt encrypt:self.data.text password:@"123456"]];
}
- (IBAction)onAESDecode:(id)sender {
    [self.AESDecodeResult setText:[AESCrypt decrypt:self.AESEncodeResult.text password:@"123456"]];
}
- (IBAction)onRSCEncode:(id)sender {
    [self.RSCEncodeResult setText:@""];
}
- (IBAction)onRSCDecode:(id)sender {
    [self.RSCDecodeResult setText:@""];
}
- (IBAction)onBase64Encode:(id)sender {
    [self.Base64EncodeResult setText:@""];
}
- (IBAction)onBase64Decode:(id)sender {
    [self.Base64DecodeResult setText:@""];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
