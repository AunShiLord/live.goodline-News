//
//  Post.h
//  live.goodline News
//
//  Created by Admin on 06.05.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface Post : NSObject

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) UIImage *preview;
@property (nonatomic, retain) NSString *link;
@property (nonatomic, retain) NSString *timePosted;

-(instancetype)init;

@end
