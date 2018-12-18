//
//  DialPadViewController.swift
//  queue
//
//  Created by Joseph Jordan on 11/10/18.
//  Copyright © 2018 queue. All rights reserved.
//

import UIKit

class DialPadViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareQueueButtons()
        setUpNumberStuff()
        setUpGestureRecognizers()
        Data.thisRec = nil
    }
    
    //======================= SETUP ====================
    func prepareQueueButtons() {
        goButton.isHidden = true
        clearButton.isHidden = true
        goButton.alpha = 0.0
        clearButton.alpha = 0.0
    }

    func setUpNumberStuff() {
        numberLabel.text = ""
        contactLabel.text = ""
        let size = 65 / 320 * self.view.frame.width
        for padSize in padSizes {
            padSize.constant = size
        }
        for pad in pads {
            pad.layer.cornerRadius = size / 2
        }
    }
    
    func setUpGestureRecognizers() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(goToDashboard))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    //=================== QUEUEING ANIMATION FUNCTIONS=========================
    func presentQueueButtons() {
        goButton.isHidden = false
        clearButton.isHidden = false
        self.navigationViewBottomConstraint.constant += 90
        UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        }, completion: { finished in
            if finished {
                UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseOut, animations: {
                    self.goButton.alpha = 1.0
                    self.clearButton.alpha = 1.0
                }, completion: nil)
            }
        })
    }
    
    func hideQueueButtons() {
        UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseOut, animations: {
            self.goButton.alpha = 0.0
            self.clearButton.alpha = 0.0
        }, completion: { (finished) in
            if finished {
                self.goButton.isHidden = true
                self.clearButton.isHidden = true
                self.navigationViewBottomConstraint.constant -= 90
                UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseOut, animations: {
                    self.view.layoutIfNeeded()
                }, completion: nil)
            }
        })
    }
    
    //======================= HELPERS ==================
    func append(str: String) {
        if (numberLabel.text ?? "") == "" {
            presentQueueButtons()
            instructions.isHidden = true
        }
        if numberLabel.text!.count == 3 || numberLabel.text!.count == 7 {
            numberLabel.text = numberLabel.text! + "-" + str
        } else {
            numberLabel.text = numberLabel.text! + str
        }
        var number = numberLabel.text!
        number.removeAll(where: {$0 == "-"})
        if number.count == 10 {
            for rec in Data.allRecs {
                if number == rec.phoneNumber {
                    Data.thisRec = rec
                    contactLabel.text = rec.getFullName()
                    return
                }
            }
        }
        Data.thisRec = nil
        contactLabel.text = ""
    }
    
    @objc func goToDashboard() {
        if Data.dialJamCallsMade > 0 {
            Data.newEvent(event: Event(date: Date(), summary: "\(Data.dialJamCallsMade) calls, \(Data.dialJamBooked) demos", ID: String(Data.nextEventTag)))
        }
        Data.dialJamBooked = 0
        Data.dialJamCallsMade = 0
        Data.dialJamPhoneNumber = ""
        Data.thisRec = nil
        Data.refreshStatusesAndHotness()
        performSegue(withIdentifier: "dialpadToDashboard", sender: self)
    }
    
    //======================= OUTLETS ====================
    
    @IBAction func deleteTriggered(_ sender: Any) {
        var str = numberLabel.text!
        if str == "" {
            return
        } else {
            if str.count == 5 || str.count == 9 {
                str.remove(at: str.index(before: str.endIndex))
                str.remove(at: str.index(before: str.endIndex))
            } else {
                str.remove(at: str.index(before: str.endIndex))
            }
        }
        numberLabel.text = str
        var number = numberLabel.text!
        number.removeAll(where: {$0 == "-"})
        if number.count == 10 {
            for rec in Data.allRecs {
                if number == rec.phoneNumber {
                    Data.thisRec = rec
                    contactLabel.text = rec.getFullName()
                    return
                }
            }
        }
        Data.thisRec = nil
        contactLabel.text = ""
        if str == "" {
            hideQueueButtons()
            instructions.isHidden = false
        }
    }
    
    @IBAction func sendTriggered(_ sender: Any) {
        var number : String = numberLabel.text!
        number.removeAll(where: {$0 == "-"})
        if number.count != 10 {
            contactLabel.text = "phone number must be 10 digits"
            return
        }
        let numberURL : NSURL = URL(string: "tel://" + number)! as NSURL
        
        UIApplication.shared.open(numberURL as URL, options: [:], completionHandler: {(success) in
            Data.dialJamPhoneNumber = number
            if let rec = Data.thisRec {
                if (rec.firstName ?? "") != "" || (rec.lastName ?? "") != "" {
                    self.performSegue(withIdentifier: "singleJam", sender: self)
                } else {
                    self.performSegue(withIdentifier: "dialJam", sender: self)
                }
            } else {
                self.performSegue(withIdentifier: "dialJam", sender: self)
            }
        })
    }
    
    @IBAction func clearTriggered(_ sender: Any) {
        numberLabel.text = ""
        instructions.isHidden = false
        contactLabel.text = ""
        hideQueueButtons()
    }
    
    
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet var padSizes: [NSLayoutConstraint]!
    
    @IBOutlet var pads: [UIButton]!
    
    @IBOutlet weak var numberLabel: UILabel!
    
    @IBOutlet weak var labelDistanceToTop: NSLayoutConstraint!
    
    @IBOutlet weak var homeButton: UIButton!
    
    @IBAction func homeButtonTriggered(_ sender: Any) {
        goToDashboard()
    }
    
    @IBAction func viewRecsTriggered(_ sender: Any) {
        if Data.dialJamCallsMade > 0 {
            Data.newEvent(event: Event(date: Date(), summary: "\(Data.dialJamCallsMade) calls, \(Data.dialJamBooked) demos", ID: String(Data.nextEventTag)))
        }
        Data.dialJamBooked = 0
        Data.dialJamCallsMade = 0
        Data.dialJamPhoneNumber = ""
        Data.thisRec = nil
        Data.refreshStatusesAndHotness()
        performSegue(withIdentifier: "dialpadToViewRecs", sender: self)
    }
    
    @IBOutlet weak var homeButtonSize: NSLayoutConstraint!
    
    @IBAction func one(_ sender: Any) {
        append(str: "1")
    }
    @IBAction func two(_ sender: Any) {
        append(str: "2")
    }
    @IBAction func three(_ sender: Any) {
        append(str: "3")
    }
    @IBAction func four(_ sender: Any) {
        append(str: "4")
    }
    @IBAction func five(_ sender: Any) {
        append(str: "5")
    }
    @IBAction func six(_ sender: Any) {
        append(str: "6")
    }
    @IBAction func seven(_ sender: Any) {
        append(str: "7")
    }
    @IBAction func eight(_ sender: Any) {
        append(str: "8")
    }
    @IBAction func nine(_ sender: Any) {
        append(str: "9")
    }
    @IBAction func zero(_ sender: Any) {
        append(str: "0")
    }
    @IBOutlet weak var twoButton: UIButton!
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var navigationViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var bottomStatusConstraint: NSLayoutConstraint!
    @IBOutlet weak var topStatusConstraint: NSLayoutConstraint!
    @IBOutlet weak var instructions: UILabel!
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
