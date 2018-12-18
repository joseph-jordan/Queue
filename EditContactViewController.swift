//
//  EditContactViewController.swift
//  queue
//
//  Created by Joseph Jordan on 12/10/18.
//  Copyright © 2018 queue. All rights reserved.
//

import UIKit

class EditContactViewController: UIViewController, UITextViewDelegate {
    var rec: Rec?

    override func viewDidLoad() {
        super.viewDidLoad()
        notesTextView.delegate = self
        rec = Data.thisRec
        if let referrer = rec!.referrer {
            if referrer != "" {
                referrerTextField.text = referrer
            } else {
                personalContactSwitch.setOn(true, animated: false)
                referrerTextField.isHidden = true
            }
        } else {
            personalContactSwitch.setOn(true, animated: false)
            referrerTextField.isHidden = true
        }
        
        starredSwitch.setOn(rec!.starred, animated: false)
        if rec!.starred {
            emojiLabel.text = "⭐️"
        } else {
            emojiLabel.text = ""
        }
        firstNameTextField.text = rec!.firstName
        lastNameTextField.text = rec!.lastName
        phoneNumberTextField.text = rec!.phoneNumber
        notesTextView.text = rec!.note
        demoScheduledStatusLabel.text = "No demo yet. Give them a call! 😊"
        if rec!.status == .Booked {
            var entries = rec!.getEntries()
            entries.sort(by: {$0.date > $1.date})
            for entry in entries {
                if entry.type == .Booked {
                    demoScheduledStatusLabel.text = entry.entryOutcome
                    break
                }
            }
            scheduleDemoButton.isHidden = true
        } else {
            cancelDemoButton.isHidden = true
            rescheduleDemo.isHidden = true
        }
        submitButton.isHidden = true
        datePicker.isHidden = true
        cancelScheduleActionButton.isHidden = true
    }
    
    //======================================DELEGATION FUNCTIONS===================================
    
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
    
    func resetVerticalOrigin() {
        setVerticalOrigin(anchor: 0)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        setVerticalOrigin(anchor: -75)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        resetVerticalOrigin()
    }
    
    
    

    //========================================OUTLETS==========================================
   
   
    @IBAction func personalContactSwitchTriggered(_ sender: Any) {
        if personalContactSwitch.isOn {
            referrerTextField.isHidden = true
        } else {
            referrerTextField.isHidden = false
        }
    }
    @IBAction func starredSwitchTriggered(_ sender: Any) {
        if starredSwitch.isOn {
            emojiLabel.text = "⭐️"
        } else {
            emojiLabel.text = ""
        }
    }
    @IBOutlet weak var emojiLabel: UILabel!
    
    @IBAction func deleteContactTriggered(_ sender: Any) {
        let alert = UIAlertController(title: "Delete Contact", message: "Are you sure you want to delete this contact?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            QueryManager.updateRecVariable(withID: self.rec!.ID, forPath: "deleted", value: "true")
             Data.allRecs.remove(at: Data.allRecs.index(of: self.rec!)!)
             self.performSegue(withIdentifier: "editContactsToDashboard", sender: self)
            }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBOutlet weak var starredSwitch: UISwitch!
    @IBOutlet weak var personalContactSwitch: UISwitch!
    @IBOutlet weak var referrerTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var rescheduleDemo: UIButton!
    @IBOutlet weak var scheduleDemoButton: UIButton!
    @IBOutlet weak var cancelDemoButton: UIButton!
    @IBOutlet weak var demoScheduledStatusLabel: UILabel!
    
    @IBAction func rescheduleTriggered(_ sender: Any) {
        datePicker.isHidden = false
        cancelScheduleActionButton.isHidden = false
        submitButton.isHidden = false
    }
    
    @IBAction func scheduleDemoTriggered(_ sender: Any) {
        datePicker.isHidden = false
        cancelScheduleActionButton.isHidden = false
        submitButton.isHidden = false
    }
    
    @IBAction func cancelDemoTriggered(_ sender: Any) {
        demoScheduledStatusLabel.text = "No demo yet. Give them a call! 😊"
        var events = Data.allEvents
        events.sort(by: {$0.date > $1.date})
        for event in events {
            if let eventRec = event.rec {
                if eventRec == rec! {
                    if event.summary.starts(with: "Demo") || event.summary.starts(with: "demo") {
                        Data.deleteEvent(event: event)
                        break
                    }
                }
            }
        }
        rec?.appendEntry(entry: Entry(type: .Cancelled))
        cancelDemoButton.isHidden = true
        scheduleDemoButton.isHidden = false
        rescheduleDemo.isHidden = true
        rec!.hot = true
    }
    
    @IBAction func cancelTriggered(_ sender: Any) {
        performSegue(withIdentifier: "doneEditingRec", sender: self)
    }
    
    @IBAction func saveTriggered(_ sender: Any) {
        let ID = rec!.ID
        if let number = phoneNumberTextField.text {
            if number == "" {return}
            if number.count != 10 {return}
            for rec in Data.allRecs {
                if rec != Data.thisRec! && rec.phoneNumber == number {
                    let alert = UIAlertController(title: "Duplicate Number", message: "A contact with this phone number already exists. You can search for them in contacts.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
            }
            QueryManager.updateRecVariable(withID: ID, forPath: "phoneNumber", value: number)
            rec!.phoneNumber = number
        } else {
            return
        }
        rec!.firstName = firstNameTextField.text
        rec!.lastName = lastNameTextField.text
        rec!.note = notesTextView.text
        rec!.starred = starredSwitch.isOn
        
        QueryManager.updateRecVariable(withID: ID, forPath: "firstName", value: firstNameTextField.text ?? "")
        QueryManager.updateRecVariable(withID: ID, forPath: "lastName", value: lastNameTextField.text ?? "")
        QueryManager.updateRecVariable(withID: ID, forPath: "notes", value: notesTextView.text ?? "")
        QueryManager.updateRecVariable(withID: ID, forPath: "starred", value: String(starredSwitch.isOn))
        if personalContactSwitch.isOn {
            QueryManager.updateRecVariable(withID: ID, forPath: "referrer", value: "")
            rec!.referrer = nil
        } else {
            QueryManager.updateRecVariable(withID: ID, forPath: "referrer", value: referrerTextField.text ?? "")
            rec!.referrer = referrerTextField.text ?? ""
        }
        performSegue(withIdentifier: "doneEditingRec", sender: self)
    }
    
    @IBAction func submitTriggered(_ sender: Any) {
        datePicker.isHidden = true
        submitButton.isHidden = true
        cancelScheduleActionButton.isHidden = true
        let newEntry: Entry
        if !rescheduleDemo.isHidden {
            newEntry = Entry(type: .Rescheduled, nextEventDate: datePicker.date)
            var events = Data.allEvents
            events.sort(by: {$0.date > $1.date})
            for event in events {
                if let eventRec = event.rec {
                    if eventRec == rec! {
                        if event.summary.starts(with: "Demo") || event.summary.starts(with: "demo") || event.summary.starts(with: "resceduled") || event.summary.starts(with: "Resceduled"){
                            Data.deleteEvent(event: event)
                            break
                        }
                    }
                }
            }
        } else {
            newEntry = Entry(type: .Booked, nextEventDate: datePicker.date)
            cancelDemoButton.isHidden = false
            rescheduleDemo.isHidden = false
            scheduleDemoButton.isHidden = true
        }
        Data.newEvent(event: Event(date: datePicker.date, summary: "Demo", rec: rec!, ID: String(Data.nextEventTag)))
        rec!.appendEntry(entry: newEntry)
        demoScheduledStatusLabel.text = newEntry.entryOutcome
        rec!.hot = false
    }
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var submitButton: UIButton!
    @IBAction func cancelScheduleActionButtonTriggered(_ sender: Any) {
        datePicker.isHidden = true
        cancelScheduleActionButton.isHidden = true
        submitButton.isHidden = true
    }
    @IBOutlet weak var cancelScheduleActionButton: UIButton!
    
}
