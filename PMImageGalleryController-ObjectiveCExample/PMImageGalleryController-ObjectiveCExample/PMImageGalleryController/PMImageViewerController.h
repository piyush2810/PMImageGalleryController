//
//  PMImageGalleryViewController.h
//  PMImageGalleryExample
//
//  Created by Genex on 3/7/17.
//  Copyright © 2017 PM. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PMImageViewerControllerDelegate <NSObject>

@optional
//Called to get frame of the cell the image is viewed from
// This is required if animated is YES in Method
//- (void) showImageAtIndex:(NSInteger)initialIndex
//            fromDataArray:(NSArray *)dataArray
//                 animated:(BOOL)animated
//This method is also required while dismissing the Image View
//If this method is not implemented the a frame Just below
// the superView frame is used for transition operations
- (CGRect)getCellFrameForIndex:(NSInteger)index;

//Called as the user scrools through the gallery
// handle if you want to know which image the user is currently viewing
- (void)visibleImageIndex:(NSInteger)index;

//Called when Image Gallery View is removed from superView
// index : - the index of the Image which was currently being viewed
//           set to INT_MAX if no data present and forcibly removed
- (void)didDismissImageGalleryViewAtIndex:(NSInteger)index;

@end

@interface PMImageViewerController : NSObject

//Init PMImageGalleryViewController obj with the View Controller in which the images are to be displayed
- (instancetype)initWithViewController:(UIViewController *)viewController;

//Call when the Images are to be displayed in full screen
//**Pass showImageAtIndex : - The Index of the image on which the user has tapped
//          fromDataArray : - The Array of FMDBModel_MedicalDoc_File objects to display images and other files
//               animated : - Animation Enabled
- (void) showImageAtIndex:(NSInteger)initialIndex
            fromDataArray:(NSArray *)dataArray
                 animated:(BOOL)animated;

//Call when the original DataArray passed is changed
- (void)reloadDataArray:(NSArray *)dataArray;

//Call when the original contents of dataArry passed are changed
- (void)reloadImageScrollView;

//Call when the Image Scroll View should be removed from superview
- (void)removeScrollView;

//background color to Image Gallery
@property (nonatomic) UIColor *overlayBackColor; //default whiteColor

//background color to Image Gallery in Full Screen Mode
@property (nonatomic) UIColor *fullScreenBackColor; //default blackColor

//Header Background Color
@property (nonatomic) UIColor *barBackcolor; //default 40/255 92/255 159/255 RGB

//Header Title Color
@property (nonatomic) UIColor *barTitleColor; //default whiteColor

//Set viewAnimationDuration to adjust animation Duration
//for Image to go from cellFrame to Full Screen
@property (nonatomic) CGFloat viewAnimationDuration; //default 0.3

//Set dismissAnimationDuration to adjust animation Duration
//for Image to go from Full Screen to cellFrame
@property (nonatomic) CGFloat dismissAnimationDuration; //default 0.2

//Disable to hide share Button in the header section
@property (nonatomic, setter=setShareEnabled:) BOOL isShareEnabled;

//Set Delegate to receive call back regarding editted and deleted files
@property (nonatomic, weak) id <PMImageViewerControllerDelegate> delegate;

@end
