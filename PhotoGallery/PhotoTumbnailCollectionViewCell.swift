//
//  PhotoTumbnailCollectionViewCell.swift
//  PhotoGallery
//
//  Created by Kevin on 11/20/15.
//  Copyright © 2015 Kevin. All rights reserved.
//

import UIKit

class PhotoTumbnailCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var image: UIImageView!
    
    
    func setThumbnailImage(thumbnailImage: UIImage){
        self.image.image = thumbnailImage
    }
    
}
