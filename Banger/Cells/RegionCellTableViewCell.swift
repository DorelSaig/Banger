//
//  RegionCellTableViewCell.swift
//  Banger
//
//  Created by Dorel Saig on 30/05/2022.
//

import UIKit

class RegionCellTableViewCell: UITableViewCell {

    
    static let identifier = "region_cell"
    @IBOutlet weak var overlay: UIVisualEffectView!
    
    static func nib() -> UINib {
        return UINib(nibName: "RegionCellTableViewCell", bundle: nil)
    }
    
    public func configure(with city:String, country:String, imgUrl:String){
        localityLabel.text = city
        countryLabel.text = country
        let url = URL(string: imgUrl)
        topImageView.kf.setImage(with: url)
        
    }
    
    @IBOutlet var topImageView: UIImageView!
    @IBOutlet var localityLabel: UILabel!
    @IBOutlet var countryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        topImageView.contentMode = .scaleAspectFill
        
// ----> if you want to add blur uncomment the code below <----
// ---->  let blureffect = UIBlurEffect(style: .prominent)
//        overlay.effect = blureffect
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
