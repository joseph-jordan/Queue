//
//  RegisterViewController.swift
//  queue
//
//  Created by Joseph Jordan on 11/7/18.
//  Copyright © 2018 queue. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        registerButton.layer.cornerRadius = 10
        registerButton.clipsToBounds = true
        setUpDelegation()
    }

    
    
    //=================================== HELPER FUNCTIONS ============================================
    
    func setVerticalOrigin(anchor: Int) {
        let moveDuration = 0.45
        let convertedAnchor = CGFloat(anchor)
        //print("the move function was triggered")
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        print("new anchor ", convertedAnchor)
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
}
