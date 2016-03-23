//
//  PlacesTableViewCell.swift
//  CMO
//
//  Created by Charl on 1/29/16.
//  Copyright © 2016 Octans Corp. All rights reserved.
//

import UIKit

class PlacesTableViewCell: UITableViewCell {
    @IBOutlet weak var placeTitleLabel: UILabel!
    @IBOutlet weak var reviewCounterLabel: UILabel!
    @IBOutlet weak var placeDescriptionLabel: UILabel!
    @IBOutlet weak var placeImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
