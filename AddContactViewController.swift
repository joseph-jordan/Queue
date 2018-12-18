//
//  AddContactViewController.swift
//  queue
//
//  Created by Joseph Jordan on 12/10/18.
//  Copyright © 2018 queue. All rights reserved.
//

import UIKit

class AddContactViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    var starred = false

    override func viewDidLoad() {
        super.viewDidLoad()
        starLabel.text = ""
        lastNameTextField.delegate = self
        firstNameTextField.delegate = self
        phoneNumberTextField.delegate = self
        referrerTextField.delegate = self
        notesTextView.delegate = self
        // Do any additional setup after loading the view.
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case firstNameTextField:
            lastNameTextField.becomeFirstResponder()
        case phoneNumberTextField:
            notesTextView.becomeFirstResponder()
        case referrerTextField:
            firstNameTextField.becomeFirstResponder()
        case lastNameTextField:
            phoneNumberTextField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        resetVerticalOrigin()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    //closes keyboard on background touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBOutlet weak var starLabel: UILabel!
    @IBAction func personalContactSwitch(_ sender: Any) {
        referrerTextField.text = ""
        referrerTextField.isHidden = !referrerTextField.isHidden
    }
    @IBOutlet weak var referrerTextField: UITextField!
    @IBAction func saveAndAddAnother(_ sender: Any) {
        if let number = phoneNumberTextField.text {
            if number == "" {return}
            if number.count != 10 {return}
            for rec in Data.allRecs {
                if rec.phoneNumber == number {
                    let alert = UIAlertController(title: "Duplicate Number", message: "A contact with this phone number already exists. You can search for them in contacts.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
            }
        } else {
            return
        }
        for button in buttons {
            button.isHidden = true
        }
        QueryManager.saveNewRec(firstName: firstNameTextField.text, lastName: lastNameTextField.text, referrer: referrerTextField.text, note: notesTextView.text, phoneNumber: phoneNumberTextField.text!, starred: starred)
        starSwitch.isOn = false
        starred = false
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
            self.referrerTextField.alpha = 0.0
            self.firstNameTextField.alpha = 0.0
            self.lastNameTextField.alpha = 0.0
            self.notesTextView.alpha = 0.0
            self.phoneNumberTextField.alpha = 0.0
            self.starLabel.alpha = 0.0
            self.starSwitch.alpha = 0.0
            self.personalContactSwitch.alpha = 0.0
        }) { (finished) in
            if finished {
                self.firstNameTextField.text = ""
                self.lastNameTextField.text = ""
                self.notesTextView.text = ""
                self.phoneNumberTextField.text = ""
                self.starLabel.text = ""
                self.referrerTextField.isHidden = self.personalContactSwitch.isOn
                UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
                    self.referrerTextField.alpha = 1.0
                    self.firstNameTextField.alpha = 1.0
                    self.lastNameTextField.alpha = 1.0
                    self.notesTextView.alpha = 1.0
                    self.phoneNumberTextField.alpha = 1.0
                    self.starLabel.alpha = 1.0
                    self.starSwitch.alpha = 1.0
                    self.personalContactSwitch.alpha = 1.0
                }, completion: { (done) in
                    if done {
                        for button in self.buttons {
                            button.isHidden = false
                        }
                    }
                })
            }
        }
    }
    @IBAction func save(_ sender: Any) {
        if let number = phoneNumberTextField.text {
            if number == "" {return}
            if number.count != 10 {return}
            for rec in Data.allRecs {
                if rec.phoneNumber == number {
                    let alert = UIAlertController(title: "Duplicate Number", message: "A contact with this phone number already exists. You can search for them in contacts.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
            }
        } else {
            return
        }
        QueryManager.saveNewRec(firstName: firstNameTextField.text, lastName: lastNameTextField.text, referrer: referrerTextField.text, note: notesTextView.text, phoneNumber: phoneNumberTextField.text!, starred: starred)
        performSegue(withIdentifier: "saveContact", sender: self)
    }
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBAction func starSwitch(_ sender: Any) {
        starred = !starred
        if starred {
            starLabel.text = "⭐️"
        } else {
            starLabel.text = ""
        }
    }
    @IBOutlet weak var starSwitch: UISwitch!
    @IBOutlet weak var personalContactSwitch: UISwitch!
    
    @IBOutlet var buttons: [UIButton]!
    
}
