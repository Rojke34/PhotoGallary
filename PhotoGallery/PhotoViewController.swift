//
//  PhotoViewController.swift
//  PhotoGallery
//
//  Created by Kevin on 11/26/15.
//  Copyright © 2015 Kevin. All rights reserved.
//

import UIKit
import Photos

class PhotoViewController: UIViewController {
    
    var assetCollection: PHAssetCollection!
    var photoAsset: PHFetchResult!
    var index: Int = 0

    @IBOutlet var imgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
        self.navigationController?.hidesBarsOnTap = true
        
        displayPhoto()
        
    }
    
    @IBAction func btnTrash(sender: AnyObject) {
        
        let alert = UIAlertController(title: "Delete Image", message: "Are you sure you want to delete this image?", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (alertAction) -> Void in
                //Delete Phot
            
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({ () -> Void in
                
                let request = PHAssetCollectionChangeRequest(forAssetCollection: self.assetCollection)
                
                request?.removeAssets([self.photoAsset[self.index]])
                
                }, completionHandler: { (success, error) -> Void in
                    print("Deleted Image -> ", success ? "success": "error")
                    alert.dismissViewControllerAnimated(true, completion: nil)
                    self.photoAsset = PHAsset.fetchAssetsInAssetCollection(self.assetCollection, options: nil)
                    if self.photoAsset.count == 0 {
                        //No photo left
                        self.imgView.image = nil
                        print("No images left!!")
                        //Pop view controller
                        self.navigationController?.popToRootViewControllerAnimated(true)
                    }
                    if self.index >= self.photoAsset.count {
                        self.index = self.photoAsset.count - 1
                    }

                    self.displayPhoto()
                    
                })
            
            }))
        
        alert.addAction(UIAlertAction(title: "No", style: .Cancel, handler: { (alertAction) -> Void in
                //Do not delete photo
            alert.dismissViewControllerAnimated(true, completion: nil)
            }))
        
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func displayPhoto(){
        let imageManager = PHImageManager.defaultManager()
        
        _ = imageManager.requestImageForAsset(self.photoAsset[self.index] as! PHAsset, targetSize: PHImageManagerMaximumSize, contentMode: .AspectFill, options: nil) { (result, info) -> Void in
            self.imgView.image = result
        }
    }


    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
