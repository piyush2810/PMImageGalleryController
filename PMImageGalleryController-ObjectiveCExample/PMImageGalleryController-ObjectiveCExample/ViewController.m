//
//  ViewController.m
//  PMImageGalleryView
//
//  Created by Genex on 3/7/17.
//  Copyright © 2017 PM. All rights reserved.
//

#import "ViewController.h"

#import "AppDelegate.h"

#import "PMImage.h"
#import "PMImageViewerController.h"

#import "CHTCollectionViewWaterfallLayout.h"

@interface ViewController () <UICollectionViewDelegate, UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout, PMImageViewerControllerDelegate>
{
    NSMutableArray *imageArray;
    PMImageViewerController *pmImageGalleryObj;
    
    NSInteger hiddenCellIndex;
}

@property (nonatomic) IBOutlet UILabel *headerLabel;
@property (nonatomic) IBOutlet UIView *headerView;
@property (nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    hiddenCellIndex = INT_MAX;
    imageArray = [[NSMutableArray alloc] init];
    
    for (int i = 1; i < 11; i++) {
        NSString *imageName = [NSString stringWithFormat:@"image%d.jpeg",i];
        [imageArray addObject:[[PMImage alloc] initWithImage:[UIImage imageNamed:imageName] thumbNailImage:nil andImageName:imageName]];
    }
    
    CHTCollectionViewWaterfallLayout *layout = (CHTCollectionViewWaterfallLayout *)self.collectionView.collectionViewLayout;
    layout.columnCount = 2;
    
    pmImageGalleryObj = [[PMImageViewerController alloc] initWithViewController:self];
    pmImageGalleryObj.delegate = self;
    pmImageGalleryObj.overlayBackColor = [UIColor clearColor];
    pmImageGalleryObj.fullScreenBackColor = [UIColor clearColor];
    pmImageGalleryObj.isShareEnabled = NO;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionView Methods
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 8;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 8;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(8, 8, 8, 8);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIImage *image = ((PMImage *)[imageArray objectAtIndex:indexPath.row % 10]).image;
    
    float cellWidth = ( [[UIScreen mainScreen] bounds].size.width / 2.0 ) - 12; //Replace the divisor with the column count requirement. Make sure to have it in float.
    
    CGRect boundingRect =  CGRectMake(0, 0, cellWidth, MAXFLOAT);
    CGRect rect = AVMakeRectWithAspectRatioInsideRect(image.size, boundingRect);
    
    CGSize size = CGSizeMake(cellWidth, rect.size.height);
    return size;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return imageArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"Cell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    cell.layer.borderWidth=1.0f;
    cell.layer.cornerRadius = 5;
    cell.layer.masksToBounds = YES;
    [[cell layer] setBorderColor:[UIColor lightGrayColor].CGColor];
    
    PMImage *pmImageObj = [imageArray objectAtIndex:indexPath.item % 10];
    
    UIImageView *collectionViewImageView = (UIImageView *)[cell viewWithTag:101];
    collectionViewImageView.image = pmImageObj.image;
    collectionViewImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    UILabel *collectionViewLabel1 = (UILabel *)[cell viewWithTag:102];
    collectionViewLabel1.text = pmImageObj.imageName;
    
    if (indexPath.item == hiddenCellIndex)
        cell.hidden = YES;
    else
        cell.hidden = NO;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [pmImageGalleryObj showImageAtIndex:indexPath.item fromDataArray:imageArray animated:YES];
}

#pragma mark - PMImageGalleryViewControllerDelegate Methods

- (CGRect)getCellFrameForIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    
    UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForItemAtIndexPath:indexPath];
    CGRect cellRect = attributes.frame;
    CGRect cellFrameInSuperview = [self.collectionView convertRect:cellRect toView:[self.collectionView superview]];
    
    return cellFrameInSuperview;
}

- (void)visibleImageIndex:(NSInteger)index
{
    hiddenCellIndex = index;
    [_collectionView reloadData];
}

- (void)didDismissImageGalleryViewAtIndex:(NSInteger)index
{
    hiddenCellIndex = INT_MAX;
    [_collectionView reloadData];
}

@end
