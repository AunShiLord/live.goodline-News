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

@interface NewsListTableView ()<UITableViewDelegate,
                                UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *posts;

@end

@implementation NewsListTableView

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    
    [self.tableView reloadData];
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
        
        // getting an preview image
        TFHppleElement *imageNode = [[[postNode firstChildWithClassName:@"preview"] firstChildWithTagName:@"a"] firstChildWithTagName:@"img"];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager GET:[imageNode objectForKey:@"src"] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             //NSLog([imageNode objectForKey:@"src"]);
             post.preview = [[UIImage alloc] initWithData:responseObject];
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
    
    //[self.tableView reloadData];
    
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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    //cell.textLabel.text = [_posts valueForKeyPath:indexPath.row];
    cell.textLabel.text = [_posts[indexPath.row] title];
    cell.imageView.image = [_posts[indexPath.row] preview];
    //cell.detailTextLabel.text = [[managedObject valueForKey:@"definition"] string];
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
