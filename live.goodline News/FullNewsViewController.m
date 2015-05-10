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
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property int yOffset;

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
        //leftBarButtonItem.tintColor = [UIColor colorWithRed:110/255.0 green:177/255.0 blue:219/255.0 alpha:1.0];
        //[self.navigationItem setLeftBarButtonItem:leftBarButtonItem];
        leftBarButtonItem.tintColor = [UIColor blackColor];
        [self.navigationItem setLeftBarButtonItem:leftBarButtonItem];
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _scrollView.scrollEnabled = TRUE;
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:212/255.0 green:139/255.0 blue:23/255.0 alpha:1.0];
}

- (void)viewWillAppear:(BOOL)animated
{
    // cleaning up scrolViews subviews
    [[_scrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _yOffset = 0;
    
    UITextView *textBlock = [[UITextView alloc] init];
    textBlock.editable = false;
    textBlock.scrollEnabled = false;
    [_scrollView addSubview:textBlock];
    textBlock.text = _postTitle;
    // geting the size of the content
    CGSize size = [textBlock systemLayoutSizeFittingSize:textBlock.contentSize];
    CGRect textRect = CGRectMake(0, _yOffset, _scrollView.frame.size.width, size.height);
    textBlock.frame = textRect;
    _yOffset += size.height;
    
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

- (void)parser: (NSData *)data
{
    // creating parser and setting Xpath for it.
    TFHpple *parser = [TFHpple hppleWithHTMLData:data];
    
    NSString *XpathString = @"//div[@class='topic-content text']";
    
    // getting a post message
    NSArray *postNodes = [parser searchWithXPathQuery:XpathString];
    TFHppleElement *postNode = postNodes[0];

    NSMutableString *str = [NSMutableString stringWithString:@""];
    for (TFHppleElement *i in postNode.children)
    {
        //NSLog(@"%@", i.content);
        NSString *tempString = @"";
        tempString = [self goDeepAndFindContent:i];

        tempString = [tempString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        //[str appendString:[[self goDeepAndFindContent:i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        [str appendString:tempString];

    }
    UITextView *textBlock = [[UITextView alloc] init];
    //str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    textBlock.text = str;
    textBlock.userInteractionEnabled = FALSE;
    NSLog(@"WHOLE TEXTORINO: ===================================== %@", str);
    textBlock.editable = FALSE;
    textBlock.scrollEnabled = FALSE;
    // geting the size of the content
    CGSize size = [textBlock systemLayoutSizeFittingSize:textBlock.contentSize];
    NSLog(@"W: %f, H: %f", size.width, size.height);
    CGRect textRect = CGRectMake(0, _yOffset, _scrollView.frame.size.width, size.height);
    //CGRect textRect = CGRectMake(0, _yOffset, _scrollView.frame.size.width, 500);
    textBlock.frame = textRect;
    _yOffset += size.height;
    [_scrollView addSubview:textBlock];
    _scrollView.contentSize = CGSizeMake(self.view.frame.size.width, _yOffset*2);

    //NSLog(@"%@",str);
    _textView.text = str;
    
}

- (NSString *)goDeepAndFindContent:(TFHppleElement *)node
{

    NSString *resultString = @"";
    if ([node.tagName isEqual:@"img"])
    {
        resultString = @"AN IMAGE HERE!!!";
        return resultString;
    }
    else if ([node isTextNode])
    {
        return node.content;
    }
    else
    {
        if ([node hasChildren])
        {
            resultString = [self goDeepAndFindContent: [node firstChild]];
        }
    }
    
    return resultString;
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
