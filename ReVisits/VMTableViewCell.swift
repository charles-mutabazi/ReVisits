//
//  VMTableViewCell.swift
//  CMO
//
//  Created by Charl on 3/10/16.
//  Copyright © 2016 Octans Corp. All rights reserved.
//

import UIKit

class VMTableViewCell: UITableViewCell {

    @IBOutlet weak var coordinateLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
