//
//  PostCell.swift
//  Banger
//
//  Created by Dorel Saig on 04/06/2022.
//

import UIKit
import Kingfisher

class PostCell: UICollectionViewCell {


    @IBOutlet weak var imageCell: UIImageView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var selectIndicator: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }
    
        public func configure(imgUrl:String){
            print(imgUrl)
            indicator.startAnimating()
            let url = URL(string: imgUrl)

            KF.url(url)
                .cacheMemoryOnly()
                .fade(duration: 0.25)
                .onSuccess{ resault in
                    self.indicator.stopAnimating()}
                .set(to: imageCell)
        }
    
    public func selected(){
        selectIndicator.isHidden = false
    }
    
    public func deselect(){
        selectIndicator.isHidden = true
    }


        
    }




