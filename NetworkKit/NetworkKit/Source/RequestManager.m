//
//  RequestManager.m
//  
//
//  Created by FengYinghao on 11/16/15.
//
//

#import "RequestManager.h"
#import "BaseRequestManager.h"

@implementation RequestManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static RequestManager *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

@end
