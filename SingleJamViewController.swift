//
//  SingleJamViewController.swift
//  queue
//
//  Created by Joseph Jordan on 12/12/18.
//  Copyright © 2018 queue. All rights reserved.
//

import UIKit
import MessageUI

class SingleJamViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMessageComposeViewControllerDelegate, UITextViewDelegate{
    var demoBooked = true

    var rec: Rec!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        historyTableView.delegate = self
        historyTableView.dataSource = self
        rec = Data.thisRec!
        Data.thisRec = nil
        recNameLabel.text = rec.getFullName()
        if let ref = rec.referrer {
            if ref == "" {
                referredByLabel.text = "Personal Contact"
            }
            referredByLabel.text = "Referred by: \(ref)"
        } else {
            referredByLabel.text = "Personal Contact"
        }
        switch (rec.hot, rec.starred) {
        case (true, true):
            emojiLabel.text = "🔥⭐️"
        case (false, true):
            emojiLabel.text = "⭐️"
        case (true, false):
            emojiLabel.text = "🔥"
        case (false , false):
            emojiLabel.text = ""
        }
        notesTextView.text = rec.note
        hideSecondaryUI()
    }
    
    //===================HELPERS=========================
    func exit() {
        QueryManager.updateRecVariable(withID: rec.ID, forPath: "notes", value: (notesTextView.text ?? ""))
        rec.note = notesTextView.text ?? ""
        performSegue(withIdentifier: "advance", sender: self)
    }
    
    func hidePrimaryUI() {
        for label in primaryLabels {
            label.isHidden = true
        }
        for button in primaryButtons {
            button.isHidden = true
        }
    }

    func hideSecondaryUI() {
        datePicker.isHidden = true
        secondaryContinueButton.isHidden = true
        secondaryBackButton.isHidden = true
    }
    
    func presentPrimaryUI() {
        for label in primaryLabels {
            label.isHidden = true
        }
        for button in primaryButtons {
            button.isHidden = true
        }
        hideSecondaryUI()
    }
    
    func presentSecondaryUI() {
        datePicker.isHidden = false
        secondaryContinueButton.isHidden = false
        secondaryBackButton.isHidden = false
        hidePrimaryUI()
    }
    
    //=================TEXT FUNCTIONS===============================
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        if (result == MessageComposeResult.sent) {
            rec.appendEntry(entry: Entry(type: .SentText))
            historyTableView.reloadData()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    //closes keyboard on background touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func setVerticalOrigin(anchor: Int) {
        let moveDuration = 0.45
        let convertedAnchor = CGFloat(anchor)
        //print("the move function was triggered")
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame.origin.y = convertedAnchor
        UIView.commitAnimations()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        setVerticalOrigin(anchor: -75)
    }
    
    //=================TABLE VIEW DELEGATION FUNCTIONS===============
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rec.getEntries().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "entryCell") as! CallEntryTableViewCell
        let entry = rec.getEntry(index: indexPath.row)
        cell.iconView.image =  UIImage(named: entry.imageFile)
        cell.dateLabel.text = entry.date.getProperDescription() + ": " + entry.entryOutcome
        return cell
    }
    
    //=================SECONDARY BUTTON ACTIONS==============
    @IBAction func secondaryBackButtonTriggered(_ sender: Any) {
        presentPrimaryUI()
    }
    
    @IBAction func continueButtonTriggered(_ sender: Any) {
        Data.dialJamCallsMade += 1
        if demoBooked{
            Data.dialJamBooked += 1
            rec.appendEntry(entry: Entry(type: .Booked, nextEventDate: datePicker.date))
            Data.newEvent(event: Event(date: datePicker.date, summary: "Demo", rec: rec, ID: String(Data.nextEventTag)))
        } else {
            rec.appendEntry(entry: Entry(type: .CallBack, nextEventDate: datePicker.date))
            Data.newEvent(event: Event(date: datePicker.date, summary: "Call Back", rec: rec, ID: String(Data.nextEventTag)))
        }
        exit()
    }
    
    //=================PRIMARY BUTTON ACTIONS====================
    @IBAction func callAgainTriggered(_ sender: Any) {
        if let number = URL(string: "tel://\(rec.phoneNumber)") {
            UIApplication.shared.open(number, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func sendTextTriggered(_ sender: Any) {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            let message: String
            if let referrer = rec.referrer {
                if referrer != "" {
                    message = "Hi \(rec.firstName ?? "")! I don't know if my name rings a bell, but this is \(referrer)'s friend \(Data.userName)! We thought you could help me out with something I'm working on for school. Can I give you a quick call?😊"
                } else {
                    message = "Hi \(rec.firstName ?? "")! This is \(Data.userName)! I thought you could help me out with something I'm working on for school. Can I give you a quick call?😊"
                }
            } else {
                message = "Hi \(rec.firstName ?? "")! This is \(Data.userName)! I thought you could help me out with something I'm working on for school. Can I give you a quick call?😊"
            }
            controller.body = message
            controller.recipients = [rec.phoneNumber]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func demoBookedTriggered(_ sender: Any) {
        demoBooked = true
        presentSecondaryUI()
    }
    
    @IBAction func nextTriggered(_ sender: Any) {
        Data.dialJamCallsMade += 1
        rec.appendEntry(entry: Entry(type: .Unreached))
        exit()
    }
    
    @IBAction func declinedTriggered(_ sender: Any) {
        let alert = UIAlertController(title: "Mark as declined", message: "Are you sure? Marking this contact as declined will remove it from active recs.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: { action in
            Data.dialJamCallsMade += 1
            self.rec.appendEntry(entry: Entry(type: .Declined))
            self.exit()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func callBackTriggered(_ sender: Any) {
        demoBooked = false
        presentSecondaryUI()
    }
    
    
    @IBOutlet var primaryLabels: [UILabel]!
    
    @IBOutlet var primaryButtons: [UIButton]!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var secondaryContinueButton: UIButton!
    
    @IBOutlet weak var secondaryBackButton: UIButton!
    
    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var historyLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    
    @IBOutlet weak var referredByLabel: UILabel!
    @IBOutlet weak var emojiLabel: UILabel!
    
    @IBOutlet weak var recNameLabel: UILabel!
    
}
