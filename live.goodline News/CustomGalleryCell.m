//
//  CustomGalleryCell.m
//  live.goodline News
//
//  Created by Admin on 02.06.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "CustomGalleryCell.h"

@implementation CustomGalleryCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setZoomScale: (CGFloat)scale animated:(BOOL)animated
{
    [self.scrollView setZoomScale:scale animated:animated];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}
@end
