//
//  NewsImageGalleryViewController.m
//  live.goodline News
//
//  Created by Admin on 02.06.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "NewsImageGalleryViewController.h"
#import "CustomGalleryCell.h"

#import <math.h>


@interface NewsImageGalleryViewController () <UICollectionViewDelegate,
                                                UICollectionViewDataSource,
                                                UIScrollViewDelegate>

//@property (strong, nonatomic) NSIndexPath *indexPath;

@end

@implementation NewsImageGalleryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.collectionView registerNib: [UINib nibWithNibName: @"CustomGalleryCell" bundle:nil] forCellWithReuseIdentifier: @"Cell"];
    // Do any additional setup after loading the view from its nib.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.currentCell inSection:0];
    
    [self.collectionView scrollToItemAtIndexPath: indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];    
    
    // rotation notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.view.frame.size.width, self.view.frame.size.height-50);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CustomGalleryCell *cell = [[CustomGalleryCell alloc] init];
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.imageView.image = ((UIImageView *)self.imageViewArray[indexPath.row]).image;
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.imageViewArray count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (void)orientationChanged:(NSNotification *)notification
{
    [self adjustViewsForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (void) adjustViewsForOrientation:(UIInterfaceOrientation) orientation
{
    [self.collectionView reloadData];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.currentCell inSection:0];
    
    [self.collectionView scrollToItemAtIndexPath: indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];

}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // unzooming prev picture

    // finding out if scrollView have reached next cell
    if (fmodf(scrollView.contentOffset.x, self.view.frame.size.width) == 0)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.currentCell inSection:0];
        CustomGalleryCell *cell = (CustomGalleryCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        [cell setZoomScale:1.0 animated:YES];
        self.currentCell = (int)(scrollView.contentOffset.x/self.view.frame.size.width);
    }

}

-(void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

@end
