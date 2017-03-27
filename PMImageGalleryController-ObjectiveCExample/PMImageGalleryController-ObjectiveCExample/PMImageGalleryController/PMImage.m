//
//  PMImage.m
//  PMImageGalleryView
//
//  Created by Genex on 3/7/17.
//  Copyright © 2017 PM. All rights reserved.
//

#import "PMImage.h"

@implementation PMImage

- (instancetype)initWithImage:(UIImage *)image thumbNailImage:(UIImage *)thumbNailImage andImageName:(NSString *)imageName
{
    self = [super init];
    if (self != nil)
    {
        self.image = image;
        self.thumbnailImage = thumbNailImage;
        self.imageName = imageName;
    }
    return self;
}

@end
