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

@interface NewsListTableView ()<UITableViewDelegate,
                                UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *posts;
@property (strong, nonatomic) FullNewsViewController *fullNewsViewController;
@property (strong, nonatomic) UINavigationController *fullNewsNavigationController;
@property int pageNumber;

@end

@implementation NewsListTableView

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.navigationItem.title = @"Новости";
    
    _fullNewsViewController = [[FullNewsViewController alloc] init];
    _fullNewsNavigationController = [[UINavigationController alloc] initWithRootViewController:_fullNewsViewController];
    _pageNumber = 1;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _posts = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:@"http://live.goodline.info/guest" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        //NSLog(@"RESPONCE: %@", responseObject);
        [self parser:responseObject];
        //NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        //NSLog(@"%@", string);
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

- (void) parser:(NSData *)responseData
{
    // creating parser and setting Xpath for it.
    TFHpple *parser = [TFHpple hppleWithHTMLData:responseData];
    
    NSString *XpathString = @"//article[@class='topic topic-type-topic js-topic out-topic']";
    
    // getting all nodes with posts from the page
    NSArray *postNodes = [parser searchWithXPathQuery:XpathString];

    for (TFHppleElement *postNode in postNodes)
    {
        Post *post = [[Post alloc] init];
        
        TFHppleElement *textPart = [postNode firstChildWithClassName:@"wraps out-topic"];
        
        // getting title of the post
        TFHppleElement *titleNode = [[[textPart firstChildWithClassName:@"topic-header"] firstChildWithClassName:@"topic-title word-wrap"] firstChildWithTagName:@"a"];
        post.title = titleNode.text;
        
        // getting link to the full version of the post
        post.linkToFullPost = [titleNode objectForKey:@"href"];
        
        // getting time of the post
        post.timePosted = [[textPart firstChildWithClassName:@"topic-header"] firstChildWithTagName:@"time"].text;
        
        // getting a link to preview image
        TFHppleElement *imageNode = [[[postNode firstChildWithClassName:@"preview"] firstChildWithTagName:@"a"] firstChildWithTagName:@"img"];
        post.linkToPreview = [imageNode objectForKey:@"src"];
        
        [_posts addObject:post];
        
    }
    
    [self.tableView reloadData];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"Cell";
    CustomCell *cell = (CustomCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {

        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CustomCell"owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    cell.mainLabel.text = [_posts[indexPath.row] title];
    [cell.imageBlock setImageWithURL: [NSURL URLWithString:[_posts[indexPath.row] linkToPreview]]];
    cell.subLabel.text = [[_posts[indexPath.row] timePosted] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return cell;
}

// Action performed after tapping on the cell
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // setting link to full post
    _fullNewsViewController.linkToFullPost = [_posts[indexPath.row] linkToFullPost];
    _fullNewsViewController.postTitle = [_posts[indexPath.row] title];
    [self presentViewController:_fullNewsNavigationController animated:YES completion:nil];
    
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // issue when dragin to the VERY last cell
    
    NSInteger totalRow = [tableView numberOfRowsInSection:indexPath.section];//first get total rows in that section by current indexPath.
    if(indexPath.row == totalRow -1)
    {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSLog([NSString stringWithFormat:@"%d",(_pageNumber+1)]);
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager GET:[NSString stringWithFormat:@"http://live.goodline.info/guest/page%ld", (NSInteger)(_pageNumber+1)] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             [self parser:responseObject];
             _pageNumber += 1;
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
