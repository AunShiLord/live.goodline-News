//
//  NewsListViewController.m
//  live.goodline News
//
//  Created by Admin on 07.05.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "NewsListViewController.h"
#import "AFNetworking.h"
#import "TFHpple.h"
#import "Post.h"
#import "FullNewsViewController.h"
#import "AppDelegate.h"

@interface NewsListViewController ()<UITableViewDelegate,
                            UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *posts;
@property (strong, nonatomic) FullNewsViewController *fullNewsViewController;
@property (strong, nonatomic) UINavigationController *fullNewsNavigationController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation NewsListViewController

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
    
    //NSLog([NSString stringWithFormat:@"%d", [_posts count]]);
    //[self.tableView reloadData];
}

- (void) parser:(NSData *)responseData
{
    // creating parser and setting Xpath for it.
    TFHpple *dictionaryParser = [TFHpple hppleWithHTMLData:responseData];
    
    NSString *XpathString = @"//article[@class='topic topic-type-topic js-topic out-topic']";
    
    // getting all nodes with posts from the page
    NSArray *postNodes = [dictionaryParser searchWithXPathQuery:XpathString];
    
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
        //NSLog(post.timePosted);
        
        // getting an preview image
        TFHppleElement *imageNode = [[[postNode firstChildWithClassName:@"preview"] firstChildWithTagName:@"a"] firstChildWithTagName:@"img"];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager GET:[imageNode objectForKey:@"src"] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             //NSLog([imageNode objectForKey:@"src"]);
             //post.preview = [[UIImage alloc] initWithData:responseObject];
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
    //return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = [_posts[indexPath.row] title];
    //cell.imageView.image = [_posts[indexPath.row] preview];
    cell.detailTextLabel.text = [_posts[indexPath.row] timePosted];
    
    return cell;
}

@end

