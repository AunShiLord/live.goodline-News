//
//  NewsListTableView.m
//  live.goodline News
//
//  Created by Admin on 06.05.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "NewsListTableView.h"
#import "AFNetworking.h"
#import "TFHpple.h"
#import "Post.h"
#import "FullNewsViewController.h"
#import "CustomCell.h"
#import "UIImageView+AFNetworking.h"
#import "DataParser.h"

@interface NewsListTableView ()<UITableViewDelegate,
                                UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *posts;
@property (strong, nonatomic) FullNewsViewController *fullNewsViewController;

@property int pageNumber;

@end

@implementation NewsListTableView

static NSString *const goodlineLink = @"http://live.goodline.info/guest";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor greenColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(getLatestNews)
                  forControlEvents:UIControlEventValueChanged];
    
    self.view.backgroundColor = [UIColor colorWithRed:86/255.0 green:207/255.0 blue:82/255.0 alpha:1.0];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.navigationItem.title = @"Новости";

    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:248/255.0 green:159/255.0 blue:48/255.0 alpha:1.0];
    
    // getting information from the page for the first time
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:[NSString stringWithFormat:@"%@/page%d", goodlineLink, 1] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [DataParser parseData:responseObject inArray:_posts];
         _pageNumber += 1;
         [self.tableView reloadData];

     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error retrieving info"
                                                             message:[error localizedDescription]
                                                            delegate:nil
                                                   cancelButtonTitle:@"Ok"
                                                   otherButtonTitles:nil];
         [alertView show];
     }];

    
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _posts = [[NSMutableArray alloc] init];
        
        _fullNewsViewController = [[FullNewsViewController alloc] init];
        
        _pageNumber = 1;
    }
    
    return self;
}

// pull to refresh
- (void) getLatestNews
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:goodlineLink parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [self pullToRefreshParser:responseObject];
         
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [self.refreshControl endRefreshing];
         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error retrieving info"
                                                             message:[error localizedDescription]
                                                            delegate:nil
                                                   cancelButtonTitle:@"Ok"
                                                   otherButtonTitles:nil];
         [self.refreshControl endRefreshing];
         [alertView show];
     }];
}

- (void) pullToRefreshParser:(NSData *)responseData
{
    // creating parser and setting Xpath for it.
    TFHpple *parser = [TFHpple hppleWithHTMLData:responseData];
    
    NSString *XpathString = @"//article[@class='topic topic-type-topic js-topic out-topic']";
    
    NSArray *postNodes = [parser searchWithXPathQuery:XpathString];
    
    NSMutableArray *newNews = [[NSMutableArray alloc] init];

    for (TFHppleElement *postNode in postNodes)
    {
        Post *post = [[Post alloc] init];
        
        TFHppleElement *textPart = [postNode firstChildWithClassName:@"wraps out-topic"];
        
        // getting title of the post
        TFHppleElement *titleNode = [[[textPart firstChildWithClassName:@"topic-header"] firstChildWithClassName:@"topic-title word-wrap"] firstChildWithTagName:@"a"];
        post.title = titleNode.text;
        
        // getting link to the full version of the post
        post.linkToFullPost = [titleNode objectForKey:@"href"];
        if ([_posts count] != 0)
            if ([post.linkToFullPost isEqual:[_posts[0] linkToFullPost]])
                break;
        
        // getting time of the post
        post.timePosted = [[textPart firstChildWithClassName:@"topic-header"] firstChildWithTagName:@"time"].text;
        
        // getting a link to preview image
        TFHppleElement *imageNode = [[[postNode firstChildWithClassName:@"preview"] firstChildWithTagName:@"a"] firstChildWithTagName:@"img"];
        if (imageNode)
        {
            post.linkToPreview = [imageNode objectForKey:@"src"];
        }

        
        [newNews addObject:post];
        
    }
    for (Post *i in _posts)
        [newNews addObject:i];
    
    _posts = newNews;
    
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_posts count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 88;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"Cell";
    CustomCell *cell = (CustomCell *)[self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {

        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CustomCell"owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    cell.mainLabel.text = [_posts[indexPath.row] title];
    if ([_posts[indexPath.row] linkToPreview])
        [cell.imageBlock setImageWithURL: [NSURL URLWithString:[_posts[indexPath.row] linkToPreview]] placeholderImage:[UIImage imageNamed:@"goodline_default.jpg"]];
    else
        cell.imageBlock.image = [UIImage imageNamed:@"goodline_default.jpg"];
    cell.subLabel.text = [[_posts[indexPath.row] timePosted] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    
    return cell;
}

// Action performed after tapping on the cell
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // setting link to full post
    _fullNewsViewController.linkToFullPost = [_posts[indexPath.row] linkToFullPost];
    _fullNewsViewController.postTitle = [_posts[indexPath.row] title];
    [self.navigationController pushViewController:_fullNewsViewController animated:YES];
    //[self presentViewController:_fullNewsNavigationController animated:YES completion:nil];
    
}

-(void) openLastNews
{
    if (![_posts count] > 0)
    {
        NSData *data = [[NSData alloc] initWithContentsOfURL:[[NSURL alloc] initWithString:goodlineLink]];
        [DataParser parseData:data inArray:_posts];
    }
    _fullNewsViewController.linkToFullPost = [_posts[0] linkToFullPost];
    _fullNewsViewController.postTitle = [_posts[0] title];
    [self.navigationController pushViewController: _fullNewsViewController animated:YES];

}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger totalRow = [tableView numberOfRowsInSection:indexPath.section];//first get total rows in that section by current indexPath.
    if(indexPath.row == totalRow -1)
    {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager GET:[NSString stringWithFormat:@"%@/page%ld",goodlineLink, (long)(_pageNumber)] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             int oldNewsCount = (int)[_posts count];
             [DataParser parseData:responseObject inArray:_posts];
             
             if (oldNewsCount != [_posts count])
             {
                 _pageNumber += 1;
             }
             
             [self.tableView reloadData];
             
         }
             failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             //NSError *error;
             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error retrieving info"
                                                                 message:[error localizedDescription]
                                                                delegate:nil
                                                       cancelButtonTitle:@"Ok"
                                                       otherButtonTitles:nil];
             [alertView show];
         }];

    }
}

@end
