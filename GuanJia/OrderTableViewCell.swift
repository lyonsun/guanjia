//
//  OrderTableViewCell.swift
//  GuanJia
//
//  Created by Liang Sun on 12/15/15.
//  Copyright © 2015 Lyon Sun. All rights reserved.
//

import UIKit

class OrderTableViewCell: UITableViewCell {

    // MARK: Properties
    
    @IBOutlet weak var buyerLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var trackingNumberLabel: UILabel!
    @IBOutlet weak var deliveryDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
