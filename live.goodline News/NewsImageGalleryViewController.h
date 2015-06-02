//
//  NewsImageGalleryViewController.h
//  live.goodline News
//
//  Created by Admin on 02.06.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsImageGalleryViewController : UIViewController

@property (strong, nonatomic) NSMutableArray *imageViewArray;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@property int currentCell;

@end
