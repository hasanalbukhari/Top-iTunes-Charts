
//
//  WebViewController.m
//  Top iTunes Charts
//
//  Created by Hasan on 12/24/14.
//  Copyright (c) 2014 Hasan. All rights reserved.
//

#import "WebViewController.h"
#import "Single.h"

#import <AFNetworking/AFNetworking.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <AFNetworking/UIAlertView+AFNetworking.h>

#import "DDLog.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation WebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navItem setTitle:self.songTitle];
    
    [self refresh];
}

- (IBAction)refresh:(id)sender {
    
    DDLogVerbose(@"Refreshing Web Page.");
    
    [self refresh];
}

- (void)refresh {
    
    shouldStartLoad = NO;
    
    AFHTTPRequestOperationManager *manager = [[Single single] sharedManager];
    
    if (operationRequest) {
        [operationRequest cancel];
        
        [self.webView stopLoading];
    }
    
    operationRequest = [manager GET:self.webLink parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *htmlString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"src-swap" withString:@"src"];
        
        DDLogVerbose(@"Song Page HTML: %@", htmlString);
        
        [self.webView loadHTMLString:htmlString baseURL:nil];
        
        shouldStartLoad = YES;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (!operation.isCancelled) {
            [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"The operation couldn't be completed." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
            
            [self.loadingIndicator stopAnimating];
            
            DDLogError(@"Error retrieving song page: %@", [error description]);
        }
    }];

    [self.loadingIndicator startAnimating];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if (shouldStartLoad) {
        shouldStartLoad = NO;
        return YES;
    }
        
    return NO;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.loadingIndicator stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
}

@end
