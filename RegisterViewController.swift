//
//  RegisterViewController.swift
//  queue
//
//  Created by Joseph Jordan on 11/7/18.
//  Copyright © 2018 queue. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class RegisterViewController: UIViewController, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        registerButton.layer.cornerRadius = 10
        registerButton.clipsToBounds = true
        setUpDelegation()
    }

    let ref = Database.database().reference()
    
    //=================================== HELPER FUNCTIONS ============================================
    
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
    
    //============================= DELEGATION =================================
    
    func setUpDelegation() {
        fullNameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        confirmPasswordField.delegate = self
        teamNumberField.delegate = self
        phoneNumberField.delegate = self
    }
    
    //closes keyboard on background touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //what happens when return is clicked
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case fullNameField:
            phoneNumberField.becomeFirstResponder()
        case phoneNumberField:
            emailField.becomeFirstResponder()
        case emailField:
            passwordField.becomeFirstResponder()
        case passwordField:
            confirmPasswordField.becomeFirstResponder()
        case confirmPasswordField:
            teamNumberField.becomeFirstResponder()
        case teamNumberField:
            teamNumberField.resignFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        resetVerticalOrigin()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case fullNameField:
            resetVerticalOrigin()
        case phoneNumberField:
            setVerticalOrigin(anchor: -36)
        case emailField:
            setVerticalOrigin(anchor: -72)
        case passwordField:
            setVerticalOrigin(anchor: -108)
        case confirmPasswordField:
            setVerticalOrigin(anchor: -144)
        case teamNumberField:
            setVerticalOrigin(anchor: -180)
        default:
            resetVerticalOrigin()
        }
    }
    
    //============================= OUTLETS ==================================
    
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var fullNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var teamNumberField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    
    
    @IBAction func registerTriggered(_ sender: Any) {
        if let name = fullNameField.text {
            if !name.contains(" ") {
                statusLabel.text = "Please enter your full name"
                return
            }
            if let email = emailField.text {
                if email == "" {
                    statusLabel.text = "Please enter a valid email"
                    return
                }
                Data.userEmail = email
                if let phoneNumber = phoneNumberField.text {
                    if !isPhoneNumber(toCheck: phoneNumber) {
                        statusLabel.text = "Please enter a valid phone number"
                        return
                    }
                    if let password = passwordField.text {
                        if let confirmedPassword = confirmPasswordField.text {
                            if confirmedPassword != password {
                                statusLabel.text = "Passwords do not match"
                                return
                            }
                            if password.count < 8 {
                                statusLabel.text = "Password must be at least 8 characters"
                                return
                            }
                            if var teamID = teamNumberField.text {
                                if teamID == "" {
                                    teamID = "0"
                                }
                                let IDnum = Int(teamID)
                                if IDnum == nil {
                                    statusLabel.text = "Please provide a valid team ID"
                                    return
                                }
                                print("got this far")
                                teamID = String(IDnum!)
                                ref.observeSingleEvent(of: .value) { (snapshot) in
                                    if let nextID = snapshot.childSnapshot(forPath: "nextTeamID").value as? Int {
                                       print("got this far")
                                            if IDnum! < nextID {
                                                let sv = UIViewController.displaySpinner(onView: self.view)
                                                Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
                                                    if let err = error {
                                                        print(err)
                                                    }
                                                    if let user = authResult?.user {
                                                        print("authentication success")
                                                        UserDefaults.standard.set(email, forKey: "email")
                                                        UserDefaults.standard.set(password, forKey: "password")
                                                        QueryManager.createUser(uid: user.uid, teamID: teamID, name: name, phoneNumber: phoneNumber, completion: {
                                                            self.performSegue(withIdentifier: "registerToDashboard", sender: self)
                                                            UIViewController.removeSpinner(spinner: sv)
                                                        })
                                                    } else {
                                                        self.statusLabel.text = "invalid input"
                                                        UIViewController.removeSpinner(spinner: sv)
                                                        print(error.debugDescription)
                                                        return
                                                    }
                                                }
                                            } else {
                                                self.statusLabel.text = "Please provide a valid team ID"
                                                return
                                            }
                                        
                                    }
                                }
                            } else {
                                statusLabel.text = "Please provide a valid team ID"
                                return
                            }
                        } else {
                            statusLabel.text = "Please confirm your password"
                            return
                        }
                    } else {
                        statusLabel.text = "Please provide a password"
                        return
                    }
                } else {
                    statusLabel.text = "Please provide a phone number"
                    return
                }
            } else {
                statusLabel.text = "Please provide an email"
                return
            }
        } else {
            statusLabel.text = "Please provide a valid name"
            return
        }
    }
    
    func isPhoneNumber(toCheck: String) -> Bool {
        let num = Int(toCheck)
        if num != nil && toCheck.count == 10 {
            return true
        } else {return false}
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
}
