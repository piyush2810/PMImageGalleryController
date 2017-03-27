//
//  PMImageGalleryViewController.m
//  PMImageGalleryExample
//
//  Created by Genex on 3/7/17.
//  Copyright © 2017 PM. All rights reserved.
//

#import "PMImageViewerController.h"

#import "PMImage.h"

#import <AVFoundation/AVFoundation.h>

#define    SCREEN_WIDTH   [UIScreen mainScreen].bounds.size.width
#define    SCREEN_HEIGHT   [UIScreen mainScreen].bounds.size.height

typedef enum ImageViewerTags {
    prevImage = 101,
    currImage = 102,
    nextImage = 103
}imageViewerTags;

@interface PMImageViewerController () <UIScrollViewDelegate, UIGestureRecognizerDelegate>
{
    UIScrollView *imageScrollView;
    
    UIViewController *hostController;
    UIView *overlayView;
    UIView *headerView;
    
    UILabel *barTitle;
    UIButton *backButton;
    UIButton *shareButton;
    
    NSMutableArray *pmDataArray;
    
    CGPoint scrollViewCenter;
    NSInteger currIndex;
    
    BOOL isZoomed;
    BOOL isSwipeToDismiss;
    BOOL isFullScreen;
    
    CGRect viewFrame;
    CGRect usedWhenCellFrameUnavailable;
    CGRect headerFrame;
}
@end

@implementation PMImageViewerController

#pragma mark - Property Methods
- (void)setDefaultPropertyValues
{
    _overlayBackColor = [UIColor whiteColor];
    _fullScreenBackColor = [UIColor blackColor];
    
    _viewAnimationDuration = .3;
    _dismissAnimationDuration = .2;
    
    _barBackcolor = [UIColor colorWithRed:40/255.0f green:92/255.0f blue:159/255.0f alpha:1.0];
    _barTitleColor = [UIColor whiteColor];
    
    viewFrame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    usedWhenCellFrameUnavailable = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
    headerFrame = CGRectMake(0, 0, SCREEN_WIDTH, hostController.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height);
}

- (void)setOverlayBackColor:(UIColor *)overlayBackColor
{
    if (_overlayBackColor != overlayBackColor)
    {
        if (overlayBackColor == [UIColor clearColor])
            NSLog(@"Overlay Background Color cannot be clearColor");
        else
            _overlayBackColor = overlayBackColor;
    }
    overlayView.backgroundColor = _overlayBackColor;
}

- (void)setFullScreenBackColor:(UIColor *)fullScreenBackColor
{
    if (_fullScreenBackColor != fullScreenBackColor)
    {
        if (fullScreenBackColor == [UIColor clearColor])
            NSLog(@"Full Screen Background Color cannot be clearColor");
        else
            _fullScreenBackColor = fullScreenBackColor;
    }
}

- (void)setBarBackcolor:(UIColor *)barBackcolor
{
    if (_barBackcolor != barBackcolor)
        _barBackcolor = barBackcolor;
    headerView.backgroundColor = _barBackcolor;
}

- (void)setBarTitleColor:(UIColor *)barTitleColor
{
    if (_barTitleColor != barTitleColor)
        _barTitleColor = barTitleColor;
    barTitle.textColor = _barTitleColor;
}

- (void)setViewAnimationDuration:(CGFloat)viewAnimationDuration
{
    if (_viewAnimationDuration != viewAnimationDuration)
        _viewAnimationDuration = viewAnimationDuration;
}

- (void)setDismissAnimationDuration:(CGFloat)dismissAnimationDuration
{
    if (_dismissAnimationDuration != dismissAnimationDuration)
        _dismissAnimationDuration = dismissAnimationDuration;
}

- (void)setShareEnabled:(BOOL)isShareEnabled
{
    if (_isShareEnabled != isShareEnabled)
        _isShareEnabled = isShareEnabled;
    
    if (_isShareEnabled)
    {
        shareButton.hidden = NO;
    }
    else
    {
        shareButton.hidden = YES;
    }
}

#pragma mark - init
- (instancetype)initWithViewController:(UIViewController *)viewController
{
    self = [super init];
    if (self != nil)
    {
        hostController = viewController;
        [self setDefaultPropertyValues];
        [self loadUI];
    }
    return self;
}

#pragma mark - Public Methods
- (void) showImageAtIndex:(NSInteger)initialIndex
            fromDataArray:(NSArray *)dataArray
                 animated:(BOOL)animated
{
    
    pmDataArray = [NSMutableArray arrayWithArray:dataArray];
    
    hostController.view.userInteractionEnabled = NO;
    
    [self loadImageScrollView:initialIndex];
    
    scrollViewCenter = [imageScrollView center];
    currIndex = initialIndex;
    
    if (animated)
    {
        CGRect animateFrame;
        if ([self.delegate respondsToSelector:@selector(getCellFrameForIndex:)])
            animateFrame = [self.delegate getCellFrameForIndex:initialIndex];
        else
            animateFrame = usedWhenCellFrameUnavailable;
        
        UIImageView *animateView = [[UIImageView alloc] initWithFrame:animateFrame];
        animateView.contentMode = UIViewContentModeScaleAspectFit;
        animateView.backgroundColor = _overlayBackColor;
        
        PMImage *PMImage_Obj = [dataArray objectAtIndex:initialIndex];
        
        if ( PMImage_Obj.thumbnailImage != nil )
        {
            animateView.image = PMImage_Obj.thumbnailImage;
        }
        else
        {
            animateView.image = PMImage_Obj.image;
        }
        
        [hostController.view addSubview:overlayView];
        [hostController.view addSubview:animateView];
        
        [UIView animateWithDuration:.4 animations:^(void){
            animateView.frame = viewFrame;
        } completion:^(BOOL finished){
            [hostController.view addSubview:imageScrollView];
            isFullScreen = YES;
            [self goFullScreen];
            [hostController.view addSubview:headerView];
            overlayView.hidden = NO;
            [animateView removeFromSuperview];
            hostController.view.userInteractionEnabled = YES;
            [self setHeaderView:initialIndex];
        }];
    }
    else
    {
        [hostController.view addSubview:imageScrollView];
        isFullScreen = YES;
        [self goFullScreen];
        [hostController.view addSubview:headerView];
        overlayView.hidden = NO;
        hostController.view.userInteractionEnabled = YES;
        [self setHeaderView:initialIndex];
    }
    
    if ([self.delegate respondsToSelector:@selector(visibleImageIndex:)])
        [self.delegate visibleImageIndex:currIndex];
}

- (void)reloadDataArray:(NSArray *)dataArray
{
    [pmDataArray removeAllObjects];
    pmDataArray = [NSMutableArray arrayWithArray:dataArray];
    
    if (pmDataArray.count == 0)
        [self removeScrollView];
    else
    {
        currIndex = currIndex >= pmDataArray.count ? pmDataArray.count - 1 : currIndex;

        [self loadImageScrollView:currIndex];
        [self setHeaderView:currIndex];
    }
}

- (void)reloadImageScrollView
{
    [self loadImageScrollView:currIndex];
    [self setHeaderView:currIndex];
}

- (void)removeScrollView
{
    overlayView.backgroundColor = _overlayBackColor;
    overlayView.hidden = YES;
    [imageScrollView removeFromSuperview];
    [overlayView removeFromSuperview];
    [headerView removeFromSuperview];
    
    if ([self.delegate respondsToSelector:@selector(didDismissImageGalleryViewAtIndex:)])
    {
        if (pmDataArray.count == 0 )
            [self.delegate didDismissImageGalleryViewAtIndex:INT_MAX];
        else
            [self.delegate didDismissImageGalleryViewAtIndex:currIndex];
    }
}

#pragma mark - Private Methods
- (void)loadUI
{
    overlayView = [[UIView alloc] initWithFrame:viewFrame];
    overlayView.backgroundColor = _overlayBackColor;
    overlayView.hidden = YES;
    
    imageScrollView = [[UIScrollView alloc] initWithFrame:viewFrame];
    imageScrollView.pagingEnabled = YES;
    imageScrollView.delegate = self;
    imageScrollView.backgroundColor = [UIColor clearColor];
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(movePanel:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [panRecognizer setDelegate:self];
    
    [imageScrollView addGestureRecognizer:panRecognizer];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    [doubleTap setNumberOfTapsRequired:2];
    doubleTap.delegate = self;
    [imageScrollView addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [singleTap setNumberOfTapsRequired:1];
    singleTap.delegate = self;
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [imageScrollView addGestureRecognizer:singleTap];
    
    headerView = [[UIView alloc] initWithFrame:headerFrame];
    headerView.backgroundColor = _barBackcolor;
    
    backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, headerFrame.size.height)];
    [backButton addTarget:self action:@selector(removeScrollView) forControlEvents:UIControlEventTouchUpInside];
    [backButton setImage:[UIImage imageNamed:@"back-arrow-white"] forState:UIControlStateNormal];
    [backButton setImageEdgeInsets:UIEdgeInsetsMake(30, 30, 15, 30)];
    [headerView addSubview:backButton];
    
    shareButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 50, 0, 50, headerFrame.size.height)];
    [shareButton addTarget:self action:@selector(shareImage:) forControlEvents:UIControlEventTouchUpInside];
    [shareButton setImage:[UIImage imageNamed:@"share-white"] forState:UIControlStateNormal];
    [shareButton setImageEdgeInsets:UIEdgeInsetsMake(30, 15, 10, 15)];
    [headerView addSubview:shareButton];
    
    barTitle = [[UILabel alloc] initWithFrame:CGRectMake(60, headerFrame.size.height - 34, SCREEN_WIDTH - 120, 21)];
    barTitle.textColor = _barTitleColor;
    barTitle.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:barTitle];
}

- (void) loadImageScrollView:(NSInteger)index
{
    isZoomed = NO;
    for (UIView *view in imageScrollView.subviews) {
        [view removeFromSuperview];
    }
    
    if (pmDataArray.count == 1)
    {
        [imageScrollView addSubview:[self scrollViewWithXOffset:0 atIndex:index withTag:currImage]];
        [imageScrollView setContentSize:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT)];
        imageScrollView.scrollEnabled = NO;
        [imageScrollView scrollRectToVisible:viewFrame animated:NO];
    }
    else if (index == 0)
    {
        [imageScrollView addSubview:[self scrollViewWithXOffset:0 atIndex:index withTag:currImage]];
        [imageScrollView addSubview:[self scrollViewWithXOffset:SCREEN_WIDTH atIndex:index + 1 withTag:nextImage]];
        [imageScrollView setContentSize:CGSizeMake(SCREEN_WIDTH * 2, SCREEN_HEIGHT)];
        [imageScrollView scrollRectToVisible:viewFrame animated:NO];
    }
    else if (index == pmDataArray.count - 1)
    {
        [imageScrollView addSubview:[self scrollViewWithXOffset:0 atIndex:index - 1 withTag:prevImage]];
        [imageScrollView addSubview:[self scrollViewWithXOffset:SCREEN_WIDTH atIndex:index withTag:currImage]];
        [imageScrollView setContentSize:CGSizeMake(SCREEN_WIDTH * 2, SCREEN_HEIGHT)];
        [imageScrollView scrollRectToVisible:CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT) animated:NO];
    }
    else
    {
        [imageScrollView addSubview:[self scrollViewWithXOffset:0 atIndex:index - 1 withTag:prevImage]];
        [imageScrollView addSubview:[self scrollViewWithXOffset:SCREEN_WIDTH atIndex:index withTag:currImage]];
        [imageScrollView addSubview:[self scrollViewWithXOffset:SCREEN_WIDTH * 2 atIndex:index + 1 withTag:nextImage]];
        [imageScrollView setContentSize:CGSizeMake(SCREEN_WIDTH * 3, SCREEN_HEIGHT)];
        [imageScrollView scrollRectToVisible:CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT) animated:NO];
    }
}

- (UIView *)scrollViewWithXOffset:(CGFloat)xOffset atIndex:(NSInteger)index withTag:(NSInteger)tag
{
    
    PMImage *PMImage_Obj = [pmDataArray objectAtIndex:index];
    
    UIImageView *img = [[UIImageView alloc] initWithFrame:viewFrame];
    img.contentMode = UIViewContentModeScaleAspectFit;
    
    UIImage *image;
    if ( PMImage_Obj.thumbnailImage != nil )
    {
        image = PMImage_Obj.thumbnailImage;
    }
    else
    {
        image = PMImage_Obj.image;
    }
    
    if (image != nil)
    {
        img.image = image;
        
        CGRect boundingRect =  CGRectMake(0, 0, SCREEN_WIDTH, MAXFLOAT);
        CGRect rect = AVMakeRectWithAspectRatioInsideRect(image.size, boundingRect);
        
        CGFloat imageHeight = fabs(rect.size.height);
        
        img.frame = CGRectMake(0, SCREEN_HEIGHT/2 - imageHeight/2, SCREEN_WIDTH, imageHeight);
    }
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(xOffset, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    scrollView.minimumZoomScale = 1.0;
    scrollView.maximumZoomScale = 6.0;
    scrollView.tag = tag;
    scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
    scrollView.delegate = self;
    
    [scrollView addSubview:img];
    return scrollView;
}

- (void)setHeaderView:(NSInteger)index
{
    PMImage *PMImage_Obj = [pmDataArray objectAtIndex:index];
    barTitle.text = PMImage_Obj.imageName;
}

- (void)shareImage:(id)sender
{
    PMImage *PMImage_Obj = [pmDataArray objectAtIndex:currIndex];
    
    NSMutableArray *shareData = [[NSMutableArray alloc] init];
    NSData *selectedImageData = UIImageJPEGRepresentation(PMImage_Obj.image, 1.0);
    [shareData addObject:selectedImageData];
    
    if ( shareData.count != 0 )
    {
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:shareData
                                                                                         applicationActivities:nil];
        
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
            [hostController presentViewController:activityController animated:YES completion:nil];
        }
    }
}

#pragma mark - Gesture Handlers
- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
    // double tap zooms in
    if ([[imageScrollView viewWithTag:currImage] isKindOfClass:[UIScrollView class]])
    {
        UIScrollView *_scrollView = [imageScrollView viewWithTag:currImage];
        if (_scrollView.zoomScale > _scrollView.minimumZoomScale)
            [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:YES];
        else
        {
            float newScale = [_scrollView zoomScale] * 2.0;
            CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:_scrollView]];
            [_scrollView zoomToRect:zoomRect animated:YES];
        }
    }
}

- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer {
    // double tap zooms in
    if (!isSwipeToDismiss)
    {
        [self goFullScreen];
    }
}

- (void)goFullScreen
{
    if (!isFullScreen)
    {
        isFullScreen = YES;
        overlayView.backgroundColor = _fullScreenBackColor;
        
        [UIView animateWithDuration:.3 animations:^(void) {
            headerView.frame = CGRectMake(0, -headerFrame.size.height, SCREEN_WIDTH, headerFrame.size.height);
        }];
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [UIApplication sharedApplication].keyWindow.windowLevel = UIWindowLevelStatusBar + 1;
    }
    else
    {
        isFullScreen = NO;
        overlayView.backgroundColor = _overlayBackColor;
        
        [UIView animateWithDuration:.3 animations:^(void){
            headerView.frame = headerFrame;
        } completion:^(BOOL finished) {
        }];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [UIApplication sharedApplication].keyWindow.windowLevel = UIWindowLevelNormal;
    }
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    UIScrollView *_scrollView = [imageScrollView viewWithTag:currImage];
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates.
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [_scrollView frame].size.height / scale;
    zoomRect.size.width  = [_scrollView frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

-(void)movePanel:(id)sender {
    [[[(UITapGestureRecognizer*)sender view] layer] removeAllAnimations];
    
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:hostController.view];
    CGPoint velocity = [(UIPanGestureRecognizer*)sender velocityInView:[sender view]];
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan)
    {
        if ( ( velocity.y > 200  || velocity.y < -200 ) && !isZoomed )
        {
            isSwipeToDismiss = YES;
            overlayView.backgroundColor = _overlayBackColor;
            overlayView.hidden = NO;
            imageScrollView.scrollEnabled = NO;
            
            imageScrollView.backgroundColor = [UIColor clearColor];

            if (isFullScreen)
                [self goFullScreen];
        }
        else
        {
            isSwipeToDismiss = NO;
        }
    }
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        if (isSwipeToDismiss)
        {
            imageScrollView.scrollEnabled = YES;
            isSwipeToDismiss = NO;
            
            CGPoint currCenter = [sender view].center;
            CGFloat dx = currCenter.x - scrollViewCenter.x;
            CGFloat dy = currCenter.y - scrollViewCenter.y;
            CGFloat distanceFromCenter= sqrt(dx*dx + dy*dy);
            
            double overlayAlpha = 10/(distanceFromCenter == 0 ? 1 : distanceFromCenter);
            if (overlayAlpha < 0.7)
            {
                hostController.view.userInteractionEnabled = NO;
                
                CGRect animateFromFrame = imageScrollView.frame;
                CGRect animateToFrame;
                if ([self.delegate respondsToSelector:@selector(getCellFrameForIndex:)])
                    animateToFrame = [self.delegate getCellFrameForIndex:currIndex];
                else
                    animateToFrame = usedWhenCellFrameUnavailable;
                
                UIImageView *animateView = [[UIImageView alloc] initWithFrame:animateFromFrame];
                animateView.contentMode = UIViewContentModeScaleAspectFit;
                animateView.backgroundColor = [UIColor clearColor];
                
                PMImage *PMImage_Obj = [pmDataArray objectAtIndex:currIndex];
                
                if ( PMImage_Obj.thumbnailImage != nil )
                {
                    animateView.image = PMImage_Obj.thumbnailImage;
                }
                else
                {
                    animateView.image = PMImage_Obj.image;
                }
                
                [hostController.view addSubview:animateView];
                imageScrollView.hidden = YES;
                
                [UIView animateWithDuration:.2 animations:^(void){
                    animateView.frame = animateToFrame;
                } completion:^(BOOL finished){
                    [animateView removeFromSuperview];
                    imageScrollView.hidden = NO;
                    imageScrollView.backgroundColor = [UIColor clearColor];
                    imageScrollView.frame = viewFrame;
                    [self removeScrollView];
                    hostController.view.userInteractionEnabled = YES;
                }];
            }
            else
            {
                overlayView.backgroundColor = _overlayBackColor;
                overlayView.hidden = NO;
                imageScrollView.backgroundColor = [UIColor clearColor];
                imageScrollView.frame = viewFrame;
            }
        }
    }
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateChanged) {
        
        if (isSwipeToDismiss)
        {
            [sender view].center = CGPointMake([sender view].center.x + translatedPoint.x, [sender view].center.y + translatedPoint.y);
            
            CGPoint currCenter = [sender view].center;
            CGFloat dx = currCenter.x - scrollViewCenter.x;
            CGFloat dy = currCenter.y - scrollViewCenter.y;
            CGFloat distanceFromCenter= sqrt(dx*dx + dy*dy);
            
            double overlayAlpha = 10/(distanceFromCenter == 0 ? 1 : distanceFromCenter);
            overlayAlpha = overlayAlpha < 0.3 ? 0.3 : overlayAlpha;
            
            if (overlayView.backgroundColor != [UIColor clearColor])
                overlayView.backgroundColor = [overlayView.backgroundColor colorWithAlphaComponent:overlayAlpha];//= [UIColor colorWithWhite:0.0 alpha:overlayAlpha];
            
            [(UIPanGestureRecognizer*)sender setTranslation:CGPointMake(0,0) inView:hostController.view];
        }
    }
}

#pragma mark - UIScrollViewDelegate Methods
- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    for (id view in [[imageScrollView viewWithTag:currImage] subviews])
    {
        if ([view isKindOfClass:[UIImageView class]])
            return view;
    }
    
    return NULL;
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    for (id view in [[imageScrollView viewWithTag:currImage] subviews])
    {
        if ([view isKindOfClass:[UIImageView class]])
        {
            UIImageView *imageView = view;
            imageView.frame = [self centeredFrameForScrollView:scrollView andUIView:view];
        }
    }
}

- (CGRect)centeredFrameForScrollView:(UIScrollView *)scroll andUIView:(UIView *)rView {
    CGSize boundsSize = scroll.bounds.size;
    CGRect frameToCenter = rView.frame;
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    }
    else {
        frameToCenter.origin.x = 0;
    }
    // center vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    }
    else {
        frameToCenter.origin.y = 0;
    }
    return frameToCenter;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale
{
    if (scale == 1.0)
        isZoomed = NO;
    else
        isZoomed = YES;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset NS_AVAILABLE_IOS(5_0)
{
    if (scrollView == imageScrollView)
    {
        NSInteger viewIndex = targetContentOffset->x/SCREEN_WIDTH;
        if (viewIndex != 1)
        {
            if (pmDataArray.count != 1)
            {
                if (viewIndex == 0 && currIndex != 0)
                {
                    currIndex--;
                }
                else if (viewIndex == 2 && currIndex != pmDataArray.count - 1)
                {
                    currIndex++;
                }
            }
            [self setHeaderView:currIndex];
        }
        if (viewIndex == 1 && currIndex == 0)
        {
            if (pmDataArray.count != 1)
            {
                currIndex++;
            }
            [self setHeaderView:currIndex];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == imageScrollView)
    {
        [self loadImageScrollView:currIndex];
        if ([self.delegate respondsToSelector:@selector(visibleImageIndex:)])
            [self.delegate visibleImageIndex:currIndex];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
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
