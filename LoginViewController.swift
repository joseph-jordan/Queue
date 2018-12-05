//
//  LoginViewController.swift
//  queue
//
//  Created by Joseph Jordan on 11/7/18.
//  Copyright © 2018 queue. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpDelegation()
        // Do any additional setup after loading the view.
    }
    
    func login() {
        performSegue(withIdentifier: "login", sender: self)
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
