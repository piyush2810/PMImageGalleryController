# PMImageGalleryController
A Gallery View Controller designed specifically to handle swipeToDismiss functionality provided in most ios Applications

# Installation
Simply drag and add the .h and .m files of PMImage and PMImageViewerController to your project and start coding

# Usage
Declare Variable globally for the class

Objective C

    PMImageViewerController *pmImageGalleryObj;
    
Swift

    var pmImageGalleryObj = PMImageViewerController()

Initialize variable wherever suitable

Objective C

    pmImageGalleryObj = [[PMImageViewerController alloc] initWithViewController:self];
    pmImageGalleryObj.overlayBackColor = [UIColor whiteColor];
    pmImageGalleryObj.fullScreenBackColor = [UIColor blackColor];
    pmImageGalleryObj.delegate = self;

Swift 

    pmImageGalleryObj = PMImageViewerController(viewController: self)
    pmImageGalleryObj.delegate = self
    pmImageGalleryObj.overlayBackColor = UIColor.white
    pmImageGalleryObj.fullScreenBackColor = UIColor.black
    
Call the method to view the Image in FullScreen Mode

Objective C

    [pmImageGalleryObj showImageAtIndex:indexPath.item fromDataArray:imageArray animated:YES];

Swift

    pmImageGalleryObj.showImage(at: indexPath.item, fromDataArray: imageArray, animated: true)
    
You can also implement delegate methods

Objective C

    - (CGRect)getCellFrameForIndex:(NSInteger)index;
    - (void)visibleImageIndex:(NSInteger)index;
    - (void)didDismissImageGalleryViewAtIndex:(NSInteger)index;

Swift

    func getCellFrame(for index: Int) -> CGRect
    func visibleImageIndex(_ index: Int)
    func didDismissImageGalleryView(at index: Int)
    
# P.S.
There is room for imporvement in this and all suggesstions and Pull Requests are welcome.
