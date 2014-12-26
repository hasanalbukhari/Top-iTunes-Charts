//
//  WebViewController.h
//  Top iTunes Charts
//
//  Created by Hasan on 12/24/14.
//  Copyright (c) 2014 Hasan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking/AFNetworking.h>

@interface WebViewController : UIViewController <UIWebViewDelegate>
{
    AFHTTPRequestOperation *operationRequest;
    BOOL shouldStartLoad;
}

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (strong, nonatomic) IBOutlet UINavigationItem *navItem;

@property (strong, nonatomic) NSString *songTitle;
@property (strong, nonatomic) NSString *webLink;

@end
