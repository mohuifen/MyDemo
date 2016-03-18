//
//  ImScreenTouchesAction.h
//  huobiSystem
//
//  Created by 张仓阁 on 14-10-27.
//  Copyright (c) 2014年 张仓阁. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImScreenTouchesAction : NSObject
+ (ImScreenTouchesAction*) getInstance;
- (void)setScreenLight;
- (void)setScreenCanDarken;
@end
