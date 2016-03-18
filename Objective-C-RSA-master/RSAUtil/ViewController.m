//
//  ViewController.m
//  RSAUtil
//
//  Created by ideawu on 7/14/15.
//  Copyright (c) 2015 ideawu. All rights reserved.
//

#import "ViewController.h"
#import "RSA.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	NSString *pubkey = @"-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDOI53uYwwr+M+Gniyx3iWU6CFi+FiF1oj4SBJK/Nzno133XfUIOcuf2ykJjpuP8b2JfGg5fUqLiDBNHZEoIbQAPw4hRZi1+hF5mvhdwIR8E1UK1YeJVpRY6AymW/IhqlxLGhdL49FvCKoJNORUH7wRCmH3gj+ly4zLHmRD2OEJnwIDAQAB\n-----END PUBLIC KEY-----";
	
	NSString *originString = @"Hello world!";

	NSString *encWithPubKey;
	NSLog(@"Original string(%d): %@", (int)originString.length, originString);
	 
	encWithPubKey = [RSA encryptString:originString publicKey:pubkey];
	NSLog(@"Enctypted with public key: %@", encWithPubKey);
}

@end
