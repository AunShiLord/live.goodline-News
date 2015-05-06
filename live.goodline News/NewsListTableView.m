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

@interface NewsListTableView ()

@end

@implementation NewsListTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
        
    }
    
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:@"https://example.com" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        [self parser:responseObject];
        NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"%@", string);
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
    
    NSString *XpathString = @"//div[@class='list-topic']/";
    NSArray *posts = [dictionaryParser searchWithXPathQuery:XpathString];
    
    for (TFHppleElement *post in posts)
    {
        TFHppleElement *textPart = [post firstChildWithClassName:@"wraps out-topic"];
        NSString *title = [[[textPart firstChildWithClassName:@"topic-header"] firstChildWithClassName:@"topic-title word-wrap"] firstChildWithTagName:@"a"].text;
        NSLog(title);
    }
    
    
    
    // if dictionaryNodes is empty, then the page is wrong
    /*
    if ([dictionaryNodes count] == 0)
    {
        /*
         [self showErrorMessage:NSLocalizedString(@"Word not found!", @"Error, word not found") withError:nil];
        self.textView.attributedText = [[NSAttributedString alloc] initWithString:@""];
        [self.searchButton setEnabled:NO];
        [self.appTitle setHidden: NO];
         }
    else
    {
        // parsing block of data
        NSArray *nonTextNodes = [[dictionaryNodes objectAtIndex:0] children];
        
        NSMutableAttributedString *parsedText = [[NSMutableAttributedString alloc] init];
        parsedText = [self goDeepAndFindText:nonTextNodes];
        
        self.textView.attributedText = parsedText;
        // formatting word. First letter in uppercase, other in lowercase.
        NSString *firstLetter = [self.textField.text substringToIndex:1];
        self.wordTitle = [[firstLetter uppercaseString] stringByAppendingString:[[self.textField.text lowercaseString] substringFromIndex:1]];
        */

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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
