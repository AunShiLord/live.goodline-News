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
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.view.frame.size.width, self.view.frame.size.height-100);
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    NSIndexPath
//    [self.collectionView cellForItemAtIndexPath:<#(NSIndexPath *)#>
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
