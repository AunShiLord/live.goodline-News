//  TodayViewController.m
//  Last news widget
//
//  Created by Admin on 14.05.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "TFHpple.h"
#import "Post.h"
#import "DataParser.h"


@interface TodayViewController () <NCWidgetProviding,
                                    NSURLConnectionDelegate>

@property (strong, nonatomic) NSMutableData *htmlData;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;
@property (strong, nonatomic) IBOutlet UIView *tapView;

@end

@implementation TodayViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    
    [self.tapView addGestureRecognizer:singleFingerTap];
    
    [self downloadPage];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    NSURL *pjURL = [NSURL URLWithString:@"goodLineNews://home/"];
    [self.extensionContext openURL:pjURL completionHandler:nil];
}

- (void) downloadPage
{
    // link to Yandex Dictionary.
    NSString *url_str = @"http://live.goodline.info/guest";
    
    // converting url string to Percent Escapes format
    NSURL *url = [NSURL URLWithString: url_str];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    [connection start];
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    
    completionHandler(NCUpdateResultNewData);
}

#pragma mark - NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    self.htmlData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to the instance variable you declared
    [self.htmlData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse
{
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // parse data
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    [DataParser parseData:self.htmlData inArray:arr];
    
    // getting first element
    Post *firstPost = arr[0];
    self.titleLabel.text = firstPost.title;
    
    UIImage* image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString: firstPost.linkToPreview]]];
    self.previewImageView.image = image;
    
    
}

@end
