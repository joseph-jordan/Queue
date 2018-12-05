//
//  EventTableViewCell.swift
//  queue
//
//  Created by Joseph Jordan on 12/1/18.
//  Copyright © 2018 queue. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        line.layer.cornerRadius = 1
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var line: UIView!
    

}
