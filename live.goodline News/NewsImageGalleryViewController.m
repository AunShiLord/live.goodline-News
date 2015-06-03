//
//  NewsImageGalleryViewController.m
//  live.goodline News
//
//  Created by Admin on 02.06.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "NewsImageGalleryViewController.h"
#import "CustomGalleryCell.h"

@interface NewsImageGalleryViewController () <UICollectionViewDelegate,
                                                UICollectionViewDataSource,
                                                UIScrollViewDelegate>

@property (strong, nonatomic) NSIndexPath *indexPath;

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

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    _indexPath = indexPath;
}

- (void) adjustViewsForOrientation:(UIInterfaceOrientation) orientation
{
    [self.collectionView reloadData];
    
    [self.collectionView scrollToItemAtIndexPath: _indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    /*
    switch (orientation)
    {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
        {

        }
            
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
        {
 
        }
            break;
        case UIInterfaceOrientationUnknown:break;
    }
     */
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // unzooming every image.
    // pretty stupid way to unzoom every cell
    for (int i=0; i<[self.imageViewArray count]; i++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        CustomGalleryCell *cell = (CustomGalleryCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        
        [cell.scrollView setZoomScale:1.0 animated:YES];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

@end
