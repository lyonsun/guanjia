//
//  ProductTableViewCell.swift
//  GuanJia
//
//  Created by Liang Sun on 12/11/15.
//  Copyright © 2015 Lyon Sun. All rights reserved.
//

import UIKit

class ProductTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var stockLabel: UILabel!
    @IBOutlet weak var photoView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
