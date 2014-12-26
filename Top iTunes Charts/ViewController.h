//
//  ViewController.h
//  Top iTunes Charts
//
//  Created by Hasan S. Al-Bukhari on 12/22/14.
//  Copyright (c) 2014 Hasan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking/AFNetworking.h>

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *songs;
    NSManagedObjectContext *default_context;
    AFHTTPRequestOperation *operationRequest;
}

@property (strong, nonatomic) IBOutlet UITableView *songsTableView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

@end
