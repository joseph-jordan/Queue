//
//  LoginViewController.swift
//  queue
//
//  Created by Joseph Jordan on 11/7/18.
//  Copyright © 2018 queue. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        if Data.firstSignIn {
            Data.firstSignIn = false
        if let email = UserDefaults.standard.value(forKey: "email") as? String {
            Data.userEmail = email
            if let password = UserDefaults.standard.value(forKey: "password") as? String {
                let sv = UIViewController.displaySpinner(onView: self.view)
                Auth.auth().signIn(withEmail: email, password: password) { (outcome, error) in
                    if let result = outcome {
                        let user = result.user
                        QueryManager.loadUserData(uid: user.uid, completion: {
                            UIViewController.removeSpinner(spinner: sv)
                            self.performSegue(withIdentifier: "login", sender: self)
                        })
                    } else {
                        UIViewController.removeSpinner(spinner: sv)
                    }
                }
            }
        }
    }
        setUpDelegation()
        // Do any additional setup after loading the view.
    }
    
    func login() {
        if let email = emailField.text {
            Data.userEmail = email
            if let password = passwordField.text {
                let sv = UIViewController.displaySpinner(onView: self.view)
                Auth.auth().signIn(withEmail: email, password: password) { (outcome, error) in
                    if let result = outcome {
                        let user = result.user
                        UserDefaults.standard.set(email, forKey: "email")
                        UserDefaults.standard.set(password, forKey: "password")
                        
                        QueryManager.loadUserData(uid: user.uid, completion: {
                            UIViewController.removeSpinner(spinner: sv)
                            self.performSegue(withIdentifier: "login", sender: self)
                        })
                    } else {
                        self.statusLabel.text = "invalid sign in"
                        UIViewController.removeSpinner(spinner: sv)
                    }
                }
            }
        }
    }
    
    //========================== SETUP ===========================
    
    
    //========================== DELEGATION ======================
    
    func setUpDelegation() {
        emailField.delegate = self
        passwordField.delegate = self
    }
    
    //closes keyboard on background touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //what happens when return is clicked
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailField:
            passwordField.becomeFirstResponder()
        case passwordField:
            passwordField.resignFirstResponder()
            login()
        default:
            textField.resignFirstResponder()
        }
        return true
    }    
    
    //========================= OUTLETS ===================
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func loginTriggered(_ sender: Any) {
        login()
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
