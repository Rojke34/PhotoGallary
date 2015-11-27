//
//  ViewController.swift
//  PhotoGallery
//
//  Created by Kevin on 11/20/15.
//  Copyright © 2015 Kevin. All rights reserved.
//

import UIKit
import Photos

let reuseIdentifier = "PhotoCell"
let albumName = "My App"

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var collectionView: UICollectionView!
    
    var albumFound: Bool = false
    var assetCollection: PHAssetCollection!
    var photoAsset: PHFetchResult!
    
    @IBAction func btnCamera(sender: AnyObject) {
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            //Load Camera
            let picker: UIImagePickerController = UIImagePickerController()
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            picker.delegate = self
            picker.allowsEditing = false
            
            self.presentViewController(picker, animated: true, completion: nil)
            
            
        } else {
            //No camera avaible
            let alert = UIAlertController(title: "Error", message: "There is no camera avaible", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (alertAction) -> Void in
                alert.dismissViewControllerAnimated(true, completion: nil)
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func btnPhotoAlbum(sender: AnyObject) {
        let picker: UIImagePickerController = UIImagePickerController()
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        picker.delegate = self
        picker.allowsEditing = false
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        
        let collection = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: fetchOptions)
        
        if collection.firstObject != nil {
            
            albumFound = true
            assetCollection = collection.firstObject as! PHAssetCollection
            
        } else {
            
            print(" Folder does not exist creating now... ", albumName)
            
            
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({ () -> Void in
                _ = PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle(albumName)

                }, completionHandler: { (success, error) -> Void in
                    
                    print("creation of folder -> %@", ((success) ? "Success":"Error"))
                    
                    if ((success)) {
                        self.albumFound = true
                    } else {
                        self.albumFound = false
                    }

            })
            
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.hidesBarsOnTap = false
        self.photoAsset = PHAsset.fetchAssetsInAssetCollection(self.assetCollection, options: nil)
        self.collectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier! as String == "FullSize"){
            let controller: PhotoViewController = segue.destinationViewController as! PhotoViewController
            let indexPath: NSIndexPath = self.collectionView.indexPathForCell(sender as! UICollectionViewCell)!
            controller.index = indexPath.item
            controller.photoAsset = self.photoAsset
            controller.assetCollection = self.assetCollection
        }
    }
    
//    MARK- UICollection
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count: Int = 0
        
        if self.photoAsset != nil {
            return self.photoAsset.count
        }
        
        return count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: PhotoTumbnailCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PhotoTumbnailCollectionViewCell
        
        let asset: PHAsset = self.photoAsset[indexPath.item] as! PHAsset
        
        PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: PHImageManagerMaximumSize, contentMode: .AspectFill, options: nil) { (result, info) -> Void in
            cell.setThumbnailImage(result!)
        }
        
        return cell
    }


    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1
    }
    
    
    //UIImagepIkecrController Delgate Methos
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info["UIImagePickerControllerOriginalImage"] as! UIImage
        
        
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({ () -> Void in
            
            let createAssetRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(image)
            let assetPlaceholder = createAssetRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: self.assetCollection, assets: self.photoAsset)
            albumChangeRequest?.addAssets([assetPlaceholder!] as NSArray)
            
            }) { (success, error) -> Void in
                
                print("Addding image to library -> ", success ? "success" : "error")
                picker.dismissViewControllerAnimated(true, completion: nil)
                
        }
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    
}

