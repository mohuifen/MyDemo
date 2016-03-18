//
//  TestCocoapodsUITests.m
//  TestCocoapodsUITests
//
//  Created by LRF on 16/3/4.
//  Copyright © 2016年 LRF. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface TestCocoapodsUITests : XCTestCase

@end

@implementation TestCocoapodsUITests
// 每个测试方法调用前执行
- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}
// 每个测试方法调用后执行
- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}
// 测试方法
- (void)testExample {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    NSLog(@"自定义测试testExample");
    int a = 3;
    XCTAssertTrue(a == 0,"a 不能等于 0 ");
    
    XCTAssert(YES, @"Pass");
}

@end
