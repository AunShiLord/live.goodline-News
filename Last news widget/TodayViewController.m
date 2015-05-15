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


@interface TodayViewController () <NCWidgetProviding,
                                    NSURLConnectionDelegate>

@property (strong, nonatomic) NSMutableData *htmlData;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //self.preferredContentSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width, 88);
    //self.preferredContentSize = CGSizeMake(50, 50);
    
    //_widgetView = [[UIView alloc] init];
    
    //[self.view addSubview:_widgetView];
    
    /*
     Post *post = [[Post alloc] init];
     post.title = @"Balala";
     NSLog(@"----==== %@ ====----", post.title);
     */
    
    [self downloadPage];
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

- (void) parseHtml: (NSMutableData *)data
{
    // creating parser and setting Xpath for it.
    TFHpple *parser = [TFHpple hppleWithHTMLData:data];
     
    NSString *XpathString = @"//article[@class='topic topic-type-topic js-topic out-topic']";
     
    // getting all nodes with posts from the page
    NSArray *postNodes = [parser searchWithXPathQuery:XpathString];
     
    TFHppleElement *postNode = postNodes[0];
    
    Post *post = [[Post alloc] init];
     
    TFHppleElement *textPart = [postNode firstChildWithClassName:@"wraps out-topic"];
     
    // getting title of the post
    TFHppleElement *titleNode = [[[textPart firstChildWithClassName:@"topic-header"] firstChildWithClassName:@"topic-title word-wrap"] firstChildWithTagName:@"a"];
    post.title = titleNode.text;
    self.titleLabel.text = titleNode.text;
    
     
    // getting link to the full version of the post
    post.linkToFullPost = [titleNode objectForKey:@"href"];
    
    // getting time of the post
    post.timePosted = [[textPart firstChildWithClassName:@"topic-header"] firstChildWithTagName:@"time"].text;
    self.timeLabel.text = [[textPart firstChildWithClassName:@"topic-header"] firstChildWithTagName:@"time"].text;
     
    // getting a link to preview image
    TFHppleElement *imageNode = [[[postNode firstChildWithClassName:@"preview"] firstChildWithTagName:@"a"] firstChildWithTagName:@"img"];
    
    if (imageNode)
    {
        UIImage* image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString: [imageNode objectForKey:@"src"]]]];
        post.linkToPreview = [imageNode objectForKey:@"src"];
        self.previewImageView.image = image;
    }
    
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
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    [self parseHtml:self.htmlData];
    
}

@end
