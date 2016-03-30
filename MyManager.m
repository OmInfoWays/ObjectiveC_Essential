//
//  MyManager.m
//  WebServices
//
//  Created by VishalSharma on 30/03/16.
//  Copyright © 2016 VishalSharma. All rights reserved.
//

#import "MyManager.h"

@interface MyManager(){}
@end

@implementation MyManager

+ (id)sharedManager
{
    static MyManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    
    return sharedMyManager;
}

- (id)init
{
    if (self = [super init])
    {
        NSLog(@"my init in My Manager");
    }
    return self;
}

@end
