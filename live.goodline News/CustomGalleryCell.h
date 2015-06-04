//
//  CustomGalleryCell.h
//  live.goodline News
//
//  Created by Admin on 02.06.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomGalleryCell : UICollectionViewCell <UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

- (void)setZoomScale: (CGFloat)scale animated:(BOOL)animated;

@end
