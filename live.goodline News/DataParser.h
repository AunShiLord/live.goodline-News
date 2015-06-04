//
//  DataParser.h
//  live.goodline News
//
//  Created by Admin on 04.06.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DataParser : NSObject

+ (void) parseData:(NSData *)responseData inArray: (NSMutableArray *) array;


@end
