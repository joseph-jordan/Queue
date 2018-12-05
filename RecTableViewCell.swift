//
//  RecTableViewCell.swift
//  queue
//
//  Created by Joseph Jordan on 11/25/18.
//  Copyright © 2018 queue. All rights reserved.
//

import UIKit

class RecTableViewCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {
    var entries : [Entry] = []
    var tableViewColor : UIColor = UIColor.white
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //=====================TABLEVIEW DELEGATION====================
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "entryCell") as! CallEntryTableViewCell
        let entry = entries[indexPath.row]
        cell.iconView.image =  UIImage(named: entry.imageFile)
        cell.dateLabel.text = entry.date.getProperDescription() + ": " + entry.entryOutcome
        cell.backgroundColor = tableViewColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 25
    }
    
    
    //=====================OUTLETS===============
    @IBOutlet weak var recNameLabel: UILabel!
    @IBOutlet weak var referrerNameLabel: UILabel!
    
    @IBOutlet weak var secondaryIconLabel: UILabel!
    
    @IBOutlet weak var primaryIconLabel: UILabel!
    
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var historyLabel: UILabel!
    @IBOutlet weak var dropdownButton: UIButton!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
}
