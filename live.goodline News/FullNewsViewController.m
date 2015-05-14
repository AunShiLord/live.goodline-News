//
//  FullNewsViewController.m
//  live.goodline News
//
//  Created by Admin on 07.05.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "FullNewsViewController.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "TFHpple.h"

@interface FullNewsViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
// y position of very last element in scrollView
@property int yOffset;

@end

@implementation FullNewsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Назад"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(back)];

        leftBarButtonItem.tintColor = [UIColor blackColor];
        [self.navigationItem setLeftBarButtonItem:leftBarButtonItem];
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:86/255.0 green:207/255.0 blue:82/255.0 alpha:1.0];
    _scrollView.scrollEnabled = TRUE;
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:248/255.0 green:159/255.0 blue:48/255.0 alpha:1.0];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    // cleaning up scrolViews subviews
    [[_scrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _yOffset = 0;
    NSMutableAttributedString *atrString = [[NSMutableAttributedString alloc] initWithString:_postTitle
                                                                    attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Bold" size:20.0f]}];
    [_scrollView setContentOffset:CGPointMake(0, 0)];
    
    UITextView *textBlock = [self createTextViewWithText:atrString];
    [_scrollView addSubview:textBlock];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:_linkToFullPost parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
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

    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@""];
    for (TFHppleElement *i in postNode.children)
    {
        // handling image
        if ([i.tagName isEqual:@"img"])
        {
            // at first setting accumulated text
            if (![str isEqual:@""])
            {
                //(void) (^showViewInScrollView)(parameterTypes) = ^returnType(parameters) {...};
                UITextView *textBlock = [self createTextViewWithText:str];
                [_scrollView addSubview:textBlock];
                _scrollView.contentSize = CGSizeMake(self.view.frame.size.width, _yOffset);
                
                str = [[NSMutableAttributedString alloc] initWithString:@""];
            }
            
            // then setting imageView
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, _yOffset, _scrollView.frame.size.width-10, _scrollView.frame.size.width*9/16)];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            [imageView setImageWithURL:[NSURL URLWithString:[i objectForKey:@"src"]]];
            
            [_scrollView addSubview:imageView];
            _yOffset += imageView.frame.size.height;
        }
        // else appending text variable
        else
        {
            NSAttributedString *tempString = [[NSAttributedString alloc] initWithString:@""];
            tempString = [self goDeepAndFindContent:i];

            //tempString = [tempString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [str appendAttributedString:tempString];
        }
    }
    
    // appending last block of text
    if (![str isEqual:@""])
    {
        UITextView *textBlock = [self createTextViewWithText:str];
        [_scrollView addSubview:textBlock];
        _scrollView.contentSize = CGSizeMake(self.view.frame.size.width, _yOffset);
    }
    [_scrollView setContentOffset:CGPointMake(0, -self.navigationController.navigationBar.frame.size.height-20)];
    
}

// Go deep in nodes and find text content
- (NSAttributedString *)goDeepAndFindContent:(TFHppleElement *)node
{
    
    NSMutableAttributedString *resultString = [[NSMutableAttributedString alloc] initWithString:@""];
    if ([node isTextNode])
    {
        // handling titles
        if ([node.parent.tagName characterAtIndex:0] == 'h')
        {
            return [[NSAttributedString alloc] initWithString: [NSString stringWithFormat:@"%@\n", node.content]
                                                   attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Bold" size:15.0f]}];
        }
        // else returning plain text
        return [[NSAttributedString alloc] initWithString:node.content
                                               attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:15.0f]}];
    }
    else
    {
        // checking if node has children. If yes than go deeper
        if ([node hasChildren])
        {
            for (TFHppleElement *subNode in node.children)
            {
                if (![subNode.tagName isEqual:@"img"])
                    [resultString appendAttributedString:[self goDeepAndFindContent: subNode]];
            }
        }
    }
    
    return resultString;
}

// creating TextView with size of input text
- (UITextView *)createTextViewWithText: (NSMutableAttributedString *) string
{
    UITextView *textBlock = [[UITextView alloc] initWithFrame:CGRectMake(0, _yOffset, _scrollView.frame.size.width, 10)];
    textBlock.attributedText = string;
    textBlock.userInteractionEnabled = FALSE;
    textBlock.editable = FALSE;
    textBlock.scrollEnabled = FALSE;
    textBlock.backgroundColor = [UIColor colorWithRed:86/255.0 green:207/255.0 blue:82/255.0 alpha:1.0];
    
    // geting the size of the content
    CGSize size = [textBlock systemLayoutSizeFittingSize:textBlock.contentSize];
    CGRect textRect = CGRectMake(0, _yOffset, _scrollView.frame.size.width, size.height);
    textBlock.frame = textRect;
    _yOffset += size.height;
    
    return textBlock;
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
