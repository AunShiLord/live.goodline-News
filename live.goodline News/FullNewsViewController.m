//
//  FullNewsViewController.m
//  live.goodline News
//
//  Created by Admin on 07.05.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "FullNewsViewController.h"
#import "AFNetworking.h"
#import "TFHpple.h"

@interface FullNewsViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation FullNewsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(back)];
        leftBarButtonItem.tintColor = [UIColor colorWithRed:110/255.0 green:177/255.0 blue:219/255.0 alpha:1.0];
        [self.navigationItem setLeftBarButtonItem:leftBarButtonItem];
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //_webView = [[UIWebView alloc] initWithFrame:_scrollView.bounds];
    //[_scrollView addSubview:_webView];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:_linkToFullPost parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         //NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
         //NSLog(@"%@", string);
         [self parser:responseObject];
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

- (void) parser: (NSData *)data
{
    // creating parser and setting Xpath for it.
    TFHpple *parser = [TFHpple hppleWithHTMLData:data];
    
    NSString *XpathString = @"//div[@class='topic-content text']";
    
    // getting all nodes with posts from the page
    NSArray *postNodes = [parser searchWithXPathQuery:XpathString];
    NSLog([NSString stringWithFormat:@"%d", [postNodes count]]);
    TFHppleElement *postNode = postNodes[0];
    NSLog(postNode.raw);
    NSLog(@"=======================");
    NSLog(postNode.text);
    
}

- (IBAction)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
