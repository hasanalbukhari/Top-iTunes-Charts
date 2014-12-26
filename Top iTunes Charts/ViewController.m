//
//  ViewController.m
//  Top iTunes Charts
//
//  Created by Hasan S. Al-Bukhari on 12/22/14.
//  Copyright (c) 2014 Hasan. All rights reserved.
//

#import "ViewController.h"
#import "WebViewController.h"
#import "GDataXMLNode.h"
#import "Single.h"
#import "Song.h"

#import <MagicalRecord/CoreData+MagicalRecord.h>
#import <SDWebImage/UIImageView+WebCache.h>

#import "DDLog.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

#define SORT_KEY @"songId"
#define SONGS_CACHE_KEY @"SONGS_CACHE_KEY"

@implementation ViewController

- (void)viewDidLayoutSubviews
{
    if ([self.songsTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.songsTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    //    update to iOS 8 and uncomment this.
    //    if ([self.songsTableView respondsToSelector:@selector(setLayoutMargins:)]) {
    //        [self.songsTableView setLayoutMargins:UIEdgeInsetsZero];
    //    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    default_context = [NSManagedObjectContext MR_defaultContext];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:SONGS_CACHE_KEY]) {
        
        DDLogVerbose(@"Songs Cached.");
        
        songs = (NSMutableArray *)[Song MR_findAllSortedBy:SORT_KEY ascending:YES inContext:default_context];
        
        [self.songsTableView reloadData];
        
    } else {
        
        DDLogVerbose(@"First time launch. Consume the web service.");
        
        [self getTopSongs];
    }
}

- (IBAction)refresh:(id)sender {
    
    DDLogVerbose(@"Refresh List. Consume the web service.");
    
    [self getTopSongs];
}

- (void)getTopSongs {
    
    AFHTTPRequestOperationManager *manager = [[Single single] sharedManager];
    
    if (operationRequest) {
        [operationRequest cancel];
    }
    
    operationRequest = [manager GET:SERVICE_URL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        DDLogVerbose(@"Response: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        
        [self parseXml:responseObject];
        [self.songsTableView reloadData];
        [self.loadingIndicator stopAnimating];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (!operation.isCancelled) {
            [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"The operation couldn't be completed." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
            
            [self.loadingIndicator stopAnimating];
            
            DDLogError(@"Error consuming service: %@", [error description]);
        }
    }];
    
    [self.loadingIndicator startAnimating];
}

- (void)parseXml:(NSData *)xmlData {
    
    NSError *error;
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
    
    if (doc == nil) {
        DDLogError(@"XML parsing error: %@", [error description]);
        return;
    }
    
    [self removeAllSongs];
    
    NSArray *songsList = [doc.rootElement elementsForName:@"entry"];
    
    NSInteger idIndex = 0;
    for (GDataXMLElement *songNode in songsList) {
        NSString *title = ((GDataXMLElement *)[[songNode elementsForName:@"title"] objectAtIndex:0]).stringValue;
        NSString *image_url = ((GDataXMLElement *)[[songNode elementsForName:@"im:image"] objectAtIndex:2]).stringValue;
        NSString *web_url = ([(GDataXMLElement *)[[songNode elementsForName:@"link"] objectAtIndex:0] attributeForName:@"href"]).stringValue;
        
        Song *song = [Song MR_createInContext:default_context];
        
        song.title = title;
        song.albumImageUrl = image_url;
        song.webLink = web_url;
        song.songId = [NSString stringWithFormat:@"%d", idIndex ++] ;
        
        [songs addObject:song];
        
        DDLogVerbose(@"Parsed Song (%@): %@\n%@\n%@\n", song.songId, song.title, song.albumImageUrl, song.webLink);
    }
    
    [default_context MR_saveNestedContexts];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SONGS_CACHE_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)removeAllSongs {
    for(id song in songs)
        [default_context deleteObject:song];
    songs = [[NSMutableArray alloc] init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"WebViewSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    int selectedIndex = [[self.songsTableView indexPathForSelectedRow] row];
    Song *song = [songs objectAtIndex:selectedIndex];
    
    WebViewController *WVC = ((WebViewController *)segue.destinationViewController);
    
    WVC.songTitle = [NSString stringWithString:song.title];
    WVC.webLink = [NSString stringWithString:song.webLink];
    
    DDLogVerbose(@"Open Song (%@): %@\n%@\n%@\n", song.songId, song.title, song.albumImageUrl, song.webLink);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return songs.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Song *song = [songs objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SongCell"];

    UIImageView *albumImageView = (UIImageView *)[cell viewWithTag:10];
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:20];
    
    [albumImageView sd_setImageWithURL:[NSURL URLWithString:song.albumImageUrl]];
    [titleLabel setText:song.title];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // update to iOS 8 and uncomment this.
    //    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
    //        [cell setLayoutMargins:UIEdgeInsetsZero];
    //    }
}

@end
