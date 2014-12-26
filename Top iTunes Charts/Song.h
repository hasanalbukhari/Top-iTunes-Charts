//
//  Song.h
//  Top iTunes Charts
//
//  Created by Hasan on 12/22/14.
//  Copyright (c) 2014 Hasan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Song : NSManagedObject {
    NSString *_songId;
    NSString *_title;
    NSString *_albumImageUrl;
    NSString *_webLink;
}

@property (nonatomic, copy) NSString *songId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *albumImageUrl;
@property (nonatomic, copy) NSString *webLink;

@end
