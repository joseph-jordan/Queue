//
//  ViewContactViewController.swift
//  queue
//
//  Created by Joseph Jordan on 12/10/18.
//  Copyright © 2018 queue. All rights reserved.
//

import UIKit
import MessageUI

class ViewContactViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMessageComposeViewControllerDelegate {
    
    var rec : Rec?

    override func viewDidLoad() {
        super.viewDidLoad()
        historyTableView.delegate = self
        historyTableView.dataSource = self
        rec = Data.thisRec
        notesTextView.text = rec!.note
        fullNameLabel.text = rec!.getFullName()
        phoneNumberLabel.text = rec!.phoneDescription()
        switch (rec!.starred, rec!.hot) {
        case (true, true):
            emojiLabel.text = "⭐️🔥"
        case (true, false):
            emojiLabel.text = "⭐️"
        case (false, true):
            emojiLabel.text = "🔥"
        case (false, false):
            emojiLabel.text = ""
        }
        if let referrer = rec!.referrer {
            if referrer != "" {
                referrerLabel.text = referrer
            } else {
                referrerLabel.text = "Personal Contact"
            }
        } else {
            referrerLabel.text = "Personal Contact"
        }
        historyLabel.text = "History (\(rec!.numCalls) calls, \(rec!.numAnswers) answers)"
        
        // Do any additional setup after loading the view.
    }
    //===========================================MESSAGE DELEGATE FUNCTIONS=====================================
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        if (result == MessageComposeResult.sent) {
            rec!.appendEntry(entry: Entry(type: .SentText))
            historyTableView.reloadData()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    //===========================================TABLE VIEW DELEGATE FUNCTIONS=====================================
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rec!.getEntries().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell") as! CallEntryTableViewCell
        let entry = rec!.getEntries()[indexPath.row]
        cell.iconView.image =  UIImage(named: entry.imageFile)
        cell.dateLabel.text = entry.date.getProperDescription() + ": " + entry.entryOutcome
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 35
    }
    
    
    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var referrerLabel: UILabel!
    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var historyLabel: UILabel!
    
    @IBAction func editButtonTriggered(_ sender: Any) {
        performSegue(withIdentifier: "editRec", sender: self)
    }
    @IBAction func callButtonTriggered(_ sender: Any) {
        let numberURL : NSURL = URL(string: "tel://" + rec!.phoneNumber)! as NSURL
        
        UIApplication.shared.open(numberURL as URL, options: [:], completionHandler: {(success) in
        })
    }
    @IBAction func backButtonTriggered(_ sender: Any) {
        if Data.homeIsDashboard {
            performSegue(withIdentifier: "viewContactToDashboard", sender: self)
        } else {
            performSegue(withIdentifier: "returnToViewRecs", sender: self)
        }
    }
    
    @IBAction func messageButtonTriggered(_ sender: Any) {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = ""
            controller.recipients = [rec!.phoneNumber]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
}
