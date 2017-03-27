//
//  ViewController.swift
//  PMImageGalleryController-SwiftExample
//
//  Created by Genex on 3/24/17.
//  Copyright © 2017 PM. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PMImageViewerControllerDelegate {
    
    var imageArray = [PMImage]()
    var pmImageGalleryObj = PMImageViewerController()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        imageArray = [(PMImage(image: UIImage(contentsOfFile: Bundle.main.path(forResource: "image1", ofType: "jpeg")!), thumbNail: nil, andImageName: "image1")),
                      (PMImage(image: UIImage(contentsOfFile: Bundle.main.path(forResource: "image2", ofType: "jpeg")!), thumbNail: nil, andImageName: "image2")),
                      (PMImage(image: UIImage(contentsOfFile: Bundle.main.path(forResource: "image3", ofType: "jpeg")!), thumbNail: nil, andImageName: "image3")),
                      (PMImage(image: UIImage(contentsOfFile: Bundle.main.path(forResource: "image4", ofType: "jpeg")!), thumbNail: nil, andImageName: "image4")),
                      (PMImage(image: UIImage(contentsOfFile: Bundle.main.path(forResource: "image5", ofType: "jpeg")!), thumbNail: nil, andImageName: "image5")),
                      (PMImage(image: UIImage(contentsOfFile: Bundle.main.path(forResource: "image6", ofType: "jpeg")!), thumbNail: nil, andImageName: "image6")),
                      (PMImage(image: UIImage(contentsOfFile: Bundle.main.path(forResource: "image7", ofType: "jpeg")!), thumbNail: nil, andImageName: "image7")),
                      (PMImage(image: UIImage(contentsOfFile: Bundle.main.path(forResource: "image8", ofType: "jpeg")!), thumbNail: nil, andImageName: "image8")),
                      (PMImage(image: UIImage(contentsOfFile: Bundle.main.path(forResource: "image9", ofType: "jpeg")!), thumbNail: nil, andImageName: "image9")),
                      (PMImage(image: UIImage(contentsOfFile: Bundle.main.path(forResource: "image10", ofType: "jpeg")!), thumbNail: nil, andImageName: "image10"))
        ]
        
        pmImageGalleryObj = PMImageViewerController(viewController: self)
        pmImageGalleryObj.delegate = self
        pmImageGalleryObj.overlayBackColor = UIColor.white
        pmImageGalleryObj.fullScreenBackColor = UIColor.black
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK - UICollectionView Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = UIColor.white
        cell.layer.borderWidth = 1.0
        cell.layer.cornerRadius = 5
        cell.layer.masksToBounds = true
        cell.layer.borderColor = UIColor.lightGray.cgColor
        
        let pmImage_Obj = imageArray[indexPath.item]
        
        let imageView : UIImageView = cell.viewWithTag(101) as! UIImageView
        imageView.image = pmImage_Obj.image
        
        let imageName : UILabel = cell.viewWithTag(102) as! UILabel
        imageName.text = pmImage_Obj.imageName
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        pmImageGalleryObj.showImage(at: indexPath.item, fromDataArray: imageArray, animated: true)
    }
    
    // MARK - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let pmImage_Obj = imageArray[indexPath.item]
        let cellWidth = UIScreen.main.bounds.size.width/2 - 12
        
        let boundingRect = CGRect(x: CGFloat(integerLiteral: 0), y: CGFloat(integerLiteral: 0), width: cellWidth, height: CGFloat(MAXFLOAT))
        let rect = AVMakeRect(aspectRatio: pmImage_Obj.image.size, insideRect: boundingRect)
        
        return CGSize(width: cellWidth, height: rect.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(integerLiteral: 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(integerLiteral: 8)
    }
    
    // Mark - PMImageViewerControllerDelegate
    func getCellFrame(for index: Int) -> CGRect {
        let indexPath = NSIndexPath(item: index, section: 0)
        
        let attributes = self.collectionView.layoutAttributesForItem(at: indexPath as IndexPath)
        let cellRect = attributes?.frame;
        let cellFrameInSuperview = self.collectionView.convert(cellRect!, to: self.collectionView.superview)
        
        return cellFrameInSuperview;
    }
    
    func visibleImageIndex(_ index: Int) {
        
    }
    
    func  didDismissImageGalleryView(at index: Int) {
        
    }
    
}

