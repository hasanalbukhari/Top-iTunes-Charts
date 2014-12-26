//
//  Single.h
//  Top iTunes Charts
//
//  Created by Hasan on 12/26/14.
//  Copyright (c) 2014 Hasan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@interface Single : NSObject {
    AFHTTPRequestOperationManager *manager;
}

@property (nonatomic, retain) AFHTTPRequestOperationManager *manager;

+ (id)single;
- (AFHTTPRequestOperationManager *)sharedManager;

@end
