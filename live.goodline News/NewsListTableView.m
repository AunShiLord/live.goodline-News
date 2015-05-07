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

@interface NewsListTableView ()<UITableViewDelegate,
                                UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *posts;
@property (strong, nonatomic) FullNewsViewController *fullNewsViewController;
@property (strong, nonatomic) UINavigationController *fullNewsNavigationController;

@end

@implementation NewsListTableView

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    _fullNewsViewController = [[FullNewsViewController alloc] init];
    _fullNewsNavigationController = [[UINavigationController alloc] initWithRootViewController:_fullNewsViewController];
    
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

- (void)viewDidAppear:(BOOL)animated
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:@"http://live.goodline.info/guest" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
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
    TFHpple *dictionaryParser = [TFHpple hppleWithHTMLData:responseData];
    
    NSString *XpathString = @"//article[@class='topic topic-type-topic js-topic out-topic']";
    
    // getting all nodes with posts from the page
    NSArray *postNodes = [dictionaryParser searchWithXPathQuery:XpathString];
    //NSLog([NSString stringWithFormat: @"Length: %ld", (long)posts.count]);
    for (TFHppleElement *postNode in postNodes)
    {
        Post *post = [[Post alloc] init];
        
        TFHppleElement *textPart = [postNode firstChildWithClassName:@"wraps out-topic"];
        // getting title of the post
        TFHppleElement *titleNode = [[[textPart firstChildWithClassName:@"topic-header"] firstChildWithClassName:@"topic-title word-wrap"] firstChildWithTagName:@"a"];
        post.title = titleNode.text;
        // getting link to the full version of the post
        post.link = [titleNode objectForKey:@"href"];
        //NSLog(post.title);
        //NSLog(post.link);
        // getting time of the post
        post.timePosted = [[textPart firstChildWithClassName:@"topic-header"] firstChildWithTagName:@"time"].text;
        //NSLog(post.timePosted);
        
        // getting an preview image
        TFHppleElement *imageNode = [[[postNode firstChildWithClassName:@"preview"] firstChildWithTagName:@"a"] firstChildWithTagName:@"img"];
        //post.preview = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[imageNode objectForKey:@"src"]]]];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[imageNode objectForKey:@"src"]]];
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
        {
            post.preview = [UIImage imageWithData:data];
        }];
        
        /*
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager GET:[imageNode objectForKey:@"src"] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             NSLog([imageNode objectForKey:@"src"]);
             post.preview = [UIImage imageWithData:responseObject];
         }
             failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             // TO DO: SET BLANK IMAGE
             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error retrieving PICTURE"
                                                                 message:[error localizedDescription]
                                                                delegate:nil
                                                       cancelButtonTitle:@"Ok"
                                                       otherButtonTitles:nil];
             [alertView show];
         }];
        */
        
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
    
    //cell.textLabel.text = [_posts valueForKeyPath:indexPath.row];
    cell.mainLabel.text = [_posts[indexPath.row] title];
    cell.imageBlock.image = [_posts[indexPath.row] preview];
    //cell.subLabel.text = [_posts[indexPath.row] timePosted];
    cell.subLabel.text = [[_posts[indexPath.row] timePosted] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return cell;
}

@end
