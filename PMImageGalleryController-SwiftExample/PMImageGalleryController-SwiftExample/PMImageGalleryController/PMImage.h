//
//  PMImage.h
//  PMImageGalleryView
//
//  Created by Genex on 3/7/17.
//  Copyright © 2017 PM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PMImage : NSObject

@property (nonatomic) UIImage *image;
@property (nonatomic) UIImage *thumbnailImage;
@property (nonatomic) NSString *imageName;

//An Single PMImage Object represents the Image that is to be displayed in PMImageViewweController
// \param image - The actual Image that is to be displayed in the Viewer
// \param thumbNailImage - The thumbNailImage is the thumbnail of the
//                         actual image that is to be displayed in the
//                         viewer. Can be set to nil if not required
// \param imageName - The Name of the image that is to be displayed
//                    along with the Image in the Viewer
- (instancetype)initWithImage:(UIImage *)image thumbNailImage:(UIImage *)thumbNailImage andImageName:(NSString *)imageName;

@end
