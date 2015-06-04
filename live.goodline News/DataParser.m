//
//  DataParser.m
//  live.goodline News
//
//  Created by Admin on 04.06.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "DataParser.h"
#import "Post.h"
#import <TFHpple.h>

@implementation DataParser

+ (void) parseData:(NSData *)responseData inArray: (NSMutableArray *) array
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
        if (imageNode)
        {
            post.linkToPreview = [imageNode objectForKey:@"src"];
        }
        
        
        [array addObject:post];
        
    }
    
}

@end
