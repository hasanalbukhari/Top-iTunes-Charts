//
//  Single.m
//  Top iTunes Charts
//
//  Created by Hasan on 12/26/14.
//  Copyright (c) 2014 Hasan. All rights reserved.
//

#import "Single.h"

@implementation Single

@synthesize manager;

+ (id)single {
    static Single *single = nil;
    @synchronized(self) {
        if (single == nil)
            single = [[self alloc] init];
    }
    return single;
}

- (id)init {
    if (self = [super init]) {
        manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return self;
}

- (AFHTTPRequestOperationManager *)sharedManager {
    return manager;
}

@end
