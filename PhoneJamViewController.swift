//
//  PhoneJamViewController.swift
//  queue
//
//  Created by Joseph Jordan on 12/2/18.
//  Copyright © 2018 queue. All rights reserved.
//

import UIKit
import MessageUI

class PhoneJamViewController: UIViewController, MFMessageComposeViewControllerDelegate,  UITableViewDelegate, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareForEntryAnimation()
        refreshLabels()
        historyTableView.delegate = self
        historyTableView.dataSource = self
        historyTableView.reloadData()
        hidePopUpView(animate: false)
        refreshOverview()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        commitEntryAnimation()
    }
    
    //==========================FILE VARIABLES================
    var callsMade = 0
    var reached = 0
    var booked = 0
    var demoBooked = false
    
    //==========================MESSAGE DELEGATION FUNCTIONS==================
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        if (result == MessageComposeResult.sent) {
            Data.callQueue[0].appendEntry(entry: Entry(type: .SentText))
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    //==========================DELEGATION FUNCTIONS===============
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Data.callQueue.count > 0 {
            return Data.callQueue[0].getEntries().count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = historyTableView.dequeueReusableCell(withIdentifier: "entryCell") as! CallEntryTableViewCell
        if Data.callQueue.count > 0 {
            let entry = Data.callQueue[0].getEntry(index: indexPath.row)
            cell.iconView.image =  UIImage(named: entry.imageFile)
            cell.dateLabel.text = entry.date.getProperDescription() + ": " + entry.entryOutcome
            return cell
        } else {
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    //===========================HELPERS=========================
    func advanceToNextRec() {
        Data.callQueue[0].isQueued = false
        QueryManager.updateRecVariable(withID: Data.callQueue[0].ID, forPath: "notes", value: (notesTextView.text ?? ""))
        Data.callQueue[0].note = notesTextView.text ?? ""
        Data.callQueue.remove(at: 0)
        refreshOverview()
        hidePopUpView(animate: true)
        animateRefreshLabels()
    }
    
    func hidePopUpView(animate: Bool) {
        popUpViewTopContraint.constant = 1000
        if animate {
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {self.view.layoutIfNeeded()}, completion: nil)
        } else {
            self.view.layoutIfNeeded()
        }
    }
    
    func presentPopUpView() {
        for item in recordResultUI {
            item.isHidden = false
        }
        for item in recordResultButtons {
            item.isHidden = false
        }
        secondaryBackButton.isHidden = true
        secondaryContinueButton.isHidden = true
        datePicker.isHidden = true
        popUpViewTopContraint.constant = 5
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseOut, animations: {self.view.layoutIfNeeded()}, completion: nil)
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
    
    func executeCall() {
        if Data.callQueue.count < 1 {return}
        if let number = URL(string: "tel://\(Data.callQueue[0].phoneNumber)") {
            UIApplication.shared.open(number, options: [:], completionHandler: {
                (success) in
                if success || !success {
                    self.presentPopUpView()
                }
            })
        }

    }
    
    //closes keyboard on background touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func refreshOverview() {
        callsMadeLabel.text = "Calls made: \(callsMade)"
        reachedLabel.text = "Reached: \(reached)"
        bookedLabel.text = "Booked: \(booked)"
        let count = Data.callQueue.count
        titleLabel.text = count == 1 ? "1 call to go" : "\(count) calls to go"
    }
    
    func animateRefreshLabels() {
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseOut, animations: {
            self.topView.alpha = 0.0
        }, completion: { (finished) in
            if finished {
                self.refreshLabels()
                UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseOut, animations: {
                    self.topView.alpha = 1.0
                }, completion: nil)
            }
        })
    }
    
    func refreshLabels() {
        if Data.callQueue.count == 0 {
            recNameLabel.text = "Jam Completed"
            notesTextView.isHidden = true
            historyTableView.isHidden = true
            referrerLabel.isHidden = true
            historyLabel.isHidden = true
            emojisLabel.isHidden = true
            notesLabel.isHidden = true
            skipButton.isHidden = true
            callButton.isHidden = true
            return
        }
        let rec = Data.callQueue[0]
        recNameLabel.text = rec.getFullName()
        if rec.referrer ?? "" != "" {
            referrerLabel.text = "Referred by \(rec.referrer!)"
        } else {
            var hasFirstName = false
            var hasLastName = false
            if let first = rec.firstName {
                if first != "" {
                    hasFirstName = true
                }
            }
            if let last = rec.lastName {
                if last != "" {
                    hasLastName = true
                }
            }
            if hasLastName || hasFirstName {
                referrerLabel.text = "Personal Contact"
            } else {
                referrerLabel.text = "Unkown"
            }
        }
        switch (rec.hot, rec.starred) {
        case (true, true):
            emojisLabel.text = "🔥⭐️"
        case (true, false):
            emojisLabel.text = "🔥"
        case (false, true):
            emojisLabel.text = "⭐️"
        case (false, false):
            emojisLabel.text = ""
        }
        if let note = rec.note {
            notesTextView.text = note
        } else {
            notesTextView.text = ""
        }
        historyLabel.text = "History (\(rec.numCalls) calls, \(rec.numAnswers) answers)"
        historyTableView.reloadData()
    }
    
    func prepareForEntryAnimation() {
        ownThePhoneCenterX.constant = -400
        goLabel.alpha = 0.0
        countdownLabel.text = "3"
        countdownLabel.alpha = 0.0
        topTrailing.constant = 1000
        bottomLeading.constant = 1000
        divider.alpha = 0.0
        callButton.alpha = 0.0
        skipButton.alpha = 0.0
        view.layoutIfNeeded()
    }
    
    func commitEntryAnimation() {
        ownThePhoneCenterX.constant = 0
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: { (finished) in
            if finished {
                UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseOut, animations: {
                    self.countdownLabel.alpha = 1.0
                }, completion: { (finished) in
                    if finished {
                        DispatchQueue.global().async {
                            let durationPerItem = 1.0
                            let arr = [2, 1]
                            for i in arr {
                                let sleepTime = UInt32(durationPerItem * 1000000.0)
                                DispatchQueue.main.async {
                                    self.countdownLabel.text = "\(i)"
                                }
                                usleep(sleepTime)
                            }
                            DispatchQueue.main.async {
                                UIView.animate(withDuration: 0.4, animations: {
                                    self.countdownLabel.alpha = 0.0
                                    self.ownThePhoneLabel.alpha = 0.0
                                }, completion: { (finished) in
                                    if finished {
                                        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
                                            self.goLabel.alpha = 1.0
                                        }, completion: { (finished) in
                                            if finished {
                                                UIView.animate(withDuration: 0.65, delay: 0.1, options: .curveEaseOut, animations: {
                                                    self.goLabel.alpha = 0.0
                                                }, completion: { (finished) in
                                                    if finished {
                                                        self.topTrailing.constant = 35
                                                        self.bottomLeading.constant = 35
                                                        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseIn, animations: {
                                                            self.view.layoutIfNeeded()
                                                            self.callButton.alpha = 1.0
                                                            self.skipButton.alpha = 1.0
                                                            self.divider.alpha = 1.0
                                                        }, completion: nil)
                                                    }
                                                })
                                            }
                                        })
                                    }
                                })
                            }
                        }
                    } })}
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func skipTriggered(_ sender: Any) {
        if Data.callQueue.count > 0 {
            QueryManager.updateRecVariable(withID: Data.callQueue[0].ID, forPath: "notes", value: (notesTextView.text ?? ""))
            Data.callQueue[0].note = notesTextView.text ?? ""
            let rec = Data.callQueue[0]
            Data.callQueue.remove(at: 0)
            Data.callQueue.append(rec)
            animateRefreshLabels()
        }
    }
    @IBAction func callTriggered(_ sender: Any) {
        executeCall()
    }
    @IBAction func exitTriggered(_ sender: Any) {
        for rec in Data.callQueue {
            rec.isQueued = false
        }
        if Data.callQueue.count > 0 {
            QueryManager.updateRecVariable(withID: Data.callQueue[0].ID, forPath: "notes", value: (notesTextView.text ?? ""))
            Data.callQueue[0].note = notesTextView.text ?? ""
        }
        Data.callQueue = []
        if callsMade > 0 {
            Data.newEvent(event: Event(date: Date(), summary: "\(callsMade) calls, \(booked) demos", ID: String(Data.nextEventTag)))
        }
        Data.refreshStatusesAndHotness()
        performSegue(withIdentifier: "exit", sender: self)
    }
    
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    
    @IBOutlet weak var ownThePhoneCenterX: NSLayoutConstraint!
    @IBOutlet weak var topLeading: NSLayoutConstraint!
    @IBOutlet weak var topTrailing: NSLayoutConstraint!
    @IBOutlet weak var bottomTrailing: NSLayoutConstraint!
    @IBOutlet weak var bottomLeading: NSLayoutConstraint!
    @IBOutlet weak var ownThePhoneLabel: UILabel!
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var goLabel: UILabel!
    @IBOutlet weak var referrerLabel: UILabel!
    @IBOutlet weak var emojisLabel: UILabel!
    
    @IBOutlet weak var historyLabel: UILabel!
    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var recNameLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var divider: UIView!
    
    @IBOutlet weak var callsMadeLabel: UILabel!
    @IBOutlet weak var reachedLabel: UILabel!
    @IBOutlet weak var bookedLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    
    @IBOutlet weak var popUpViewTopContraint: NSLayoutConstraint!
    
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
            self.callsMade += 1
            self.reached += 1
            Data.callQueue[0].appendEntry(entry: Entry(type: .Declined))
            self.advanceToNextRec()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        
    }
    @IBAction func continueTriggered(_ sender: Any) {
        callsMade += 1
        Data.callQueue[0].appendEntry(entry: Entry(type: .Unreached))
        advanceToNextRec()
    }
    @IBAction func callAgainTriggered(_ sender: Any) {
        if Data.callQueue.count < 1 {return}
        if let number = URL(string: "tel://\(Data.callQueue[0].phoneNumber)") {
            UIApplication.shared.open(number, options: [:], completionHandler: nil)
        }
    }
    @IBAction func sendTextTriggered(_ sender: Any) {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            let rec = Data.callQueue[0]
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
            controller.recipients = [Data.callQueue[0].phoneNumber]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
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
    @IBOutlet weak var notesLabel: UILabel!
    @IBAction func secondaryContinueTriggered(_ sender: Any) {
        callsMade += 1
        reached += 1
        if demoBooked {
            booked += 1
            Data.callQueue[0].appendEntry(entry: Entry(type: .Booked, nextEventDate: datePicker.date))
            Data.newEvent(event: Event(date: datePicker.date, summary: "Demo", rec: Data.callQueue[0], ID: String(Data.nextEventTag)))
        } else {
            Data.callQueue[0].appendEntry(entry: Entry(type: .CallBack, nextEventDate: datePicker.date))
            Data.newEvent(event: Event(date: datePicker.date, summary: "Call Back", rec: Data.callQueue[0], ID: String(Data.nextEventTag)))
        }
        advanceToNextRec()
    }
}
