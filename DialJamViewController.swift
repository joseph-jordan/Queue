//
//  DialJamViewController.swift
//  queue
//
//  Created by Joseph Jordan on 12/11/18.
//  Copyright © 2018 queue. All rights reserved.
//

import UIKit
import MessageUI

class DialJamViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMessageComposeViewControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    var demoBooked = false
    var rec : Rec!
    override func viewDidLoad() {
        super.viewDidLoad()
        referrerTextField.delegate = self
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        notesTextView.delegate = self
        historyTableView.dataSource = self
        historyTableView.delegate = self
        if let this = Data.thisRec {
            rec = this
        } else {
            rec = QueryManager.saveNewRec(firstName: nil, lastName: nil, referrer: nil, note: nil, phoneNumber: Data.dialJamPhoneNumber, starred: false)
        }
        historyLabel.text = "History (\(rec.numCalls) calls, \(rec.numAnswers) answers)"
        quickSaveLabel.text = "Auto Save: \(rec.phoneDescription())"
        referrerTextField.text = rec.referrer
        starSwitch.setOn(rec.starred, animated: false)
        notesTextView.text = rec.note
        secondaryBackButton.isHidden = true
        secondaryContinueButton.isHidden = true
        datePicker.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    //=======================TABLE VIEW DELEGATION======================
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    //=========================TEXT FIELD DELEGATION========================
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

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case firstNameTextField:
            lastNameTextField.becomeFirstResponder()
        case referrerTextField:
            firstNameTextField.becomeFirstResponder()
        case lastNameTextField:
            notesTextView.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
    
    func resetVerticalOrigin() {
        setVerticalOrigin(anchor: 0)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        resetVerticalOrigin()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        setVerticalOrigin(anchor: -75)
    }
    
    //=========================HELPERS======================
    func advance() {
        performSegue(withIdentifier: "exit", sender: self)
    }
    
    func save() {
        let ID = rec.ID
        rec.firstName = firstNameTextField.text
        rec.lastName = lastNameTextField.text
        rec.note = notesTextView.text
        rec.starred = starSwitch.isOn
        
        QueryManager.updateRecVariable(withID: ID, forPath: "firstName", value: firstNameTextField.text ?? "")
        QueryManager.updateRecVariable(withID: ID, forPath: "lastName", value: lastNameTextField.text ?? "")
        QueryManager.updateRecVariable(withID: ID, forPath: "notes", value: notesTextView.text ?? "")
        QueryManager.updateRecVariable(withID: ID, forPath: "starred", value: String(starSwitch.isOn))
        if personalContactSwitch.isOn {
            QueryManager.updateRecVariable(withID: ID, forPath: "referrer", value: "")
            rec.referrer = nil
        } else {
            QueryManager.updateRecVariable(withID: ID, forPath: "referrer", value: referrerTextField.text ?? "")
            if referrerTextField.text ?? "" == "" {
                rec.referrer = nil
            } else {
                rec.referrer = referrerTextField.text
            }
        }
    }
    
    func presentSecondaryOptions() {
        for item in recordResultUI {
            item.isHidden = true
        }
        for item in recordResultButtons {
            item.isHidden = true
        }
        secondaryBackButton.isHidden = false
        secondaryContinueButton.isHidden = false
        datePicker.isHidden = false
    }
    
    //================================TEXTING FUNCTIONS=====================================
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
    
    func composeText() {
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    //===========================OUTLETS===========================
    @IBOutlet weak var referrerTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var personalContactSwitch: UISwitch!
    @IBOutlet weak var starSwitch: UISwitch!
    @IBOutlet weak var historyLabel: UILabel!
    @IBOutlet weak var quickSaveLabel: UILabel!
    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var notesTextView: UITextView!
    
    @IBOutlet var recordResultUI: [UILabel]!
    
    @IBOutlet var recordResultButtons: [UIButton]!
    @IBAction func demoBookedTriggered(_ sender: Any) {
        demoBooked = true
        presentSecondaryOptions()
    }
    @IBAction func callBackTriggered(_ sender: Any) {
        demoBooked = false
        presentSecondaryOptions()
    }
    
    @IBAction func declinedTriggered(_ sender: Any) {
        let alert = UIAlertController(title: "Mark as declined", message: "Are you sure? Marking this contact as declined will remove it from active recs.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: { action in
            Data.dialJamCallsMade += 1
            self.rec.appendEntry(entry: Entry(type: .Declined))
            self.save()
            self.advance()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func continueTriggered(_ sender: Any) {
        Data.dialJamCallsMade += 1
        rec.appendEntry(entry: Entry(type: .Unreached))
        save()
        advance()
    }
    @IBAction func callAgainTriggered(_ sender: Any) {
        if let number = URL(string: "tel://\(rec.phoneNumber)") {
            UIApplication.shared.open(number, options: [:], completionHandler: nil)
        }
    }
        
    @IBAction func sendTextTriggered(_ sender: Any) {
        composeText()
    }
    
    
    @IBAction func secondaryBackTriggered(_ sender: Any) {
        datePicker.isHidden = true
        secondaryContinueButton.isHidden = true
        secondaryBackButton.isHidden = true
        for item in recordResultButtons {
            item.isHidden = false
        }
        for item in recordResultUI {
            item.isHidden = false
        }
    }
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var secondaryContinueButton: UIButton!
    @IBOutlet weak var secondaryBackButton: UIButton!
    @IBAction func secondaryContinueTriggered(_ sender: Any) {
        save()
        Data.dialJamCallsMade += 1
        if demoBooked {
            Data.dialJamBooked += 1
            rec.appendEntry(entry: Entry(type: .Booked, nextEventDate: datePicker.date))
            Data.newEvent(event: Event(date: datePicker.date, summary: "Demo", rec: rec, ID: String(Data.nextEventTag)))
        } else {
            rec.appendEntry(entry: Entry(type: .CallBack, nextEventDate: datePicker.date))
            Data.newEvent(event: Event(date: datePicker.date, summary: "Call Back", rec: rec, ID: String(Data.nextEventTag)))
        }
        advance()
    }
    
    @IBAction func personalContactSwitchTriggered(_ sender: Any) {
        if personalContactSwitch.isOn {
            referrerTextField.isHidden = true
        } else {
            referrerTextField.isHidden = false
        }
    }
    
    @IBAction func starSwitchTriggered(_ sender: Any) {
        if starSwitch.isOn {
            quickSaveLabel.text = quickSaveLabel.text! + "⭐️"
        } else {
            quickSaveLabel.text = ("Auto Save: \(rec.phoneDescription())")
        }
    }
    
    
}
