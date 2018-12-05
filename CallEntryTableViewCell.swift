//
//  CallEntryTableViewCell.swift
//  queue
//
//  Created by Joseph Jordan on 11/29/18.
//  Copyright © 2018 queue. All rights reserved.
//

import UIKit

class CallEntryTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBOutlet weak var outcomeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
}
