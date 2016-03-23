//
//  PlaceTableViewCell.swift
//  CMO
//
//  Created by Charl on 1/29/16.
//  Copyright © 2016 Octans Corp. All rights reserved.
//

import UIKit

class PlaceTableViewCell: UITableViewCell {
    @IBOutlet weak var reviewDescriptionLabel: UILabel!
    @IBOutlet weak var reviewLikesCounterLabel: UILabel!
    @IBOutlet weak var reviewCommentsCounterLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
