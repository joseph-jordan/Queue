//
//  SettingsViewController.swift
//  queue
//
//  Created by Joseph Jordan on 12/9/18.
//  Copyright © 2018 queue. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import MessageUI
import Contacts

class SettingsViewController: UIViewController, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func sendEmail() {
        if (MFMailComposeViewController.canSendMail()) {
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            // Configure the fields of the interface.
            composeVC.setToRecipients(["josjord@seas.upenn.edu"])
            composeVC.setSubject("Queue Feedback")
            composeVC.setMessageBody("Hi Joe,\n\nBest,\n\(Data.userName)", isHTML: false)
            // Present the view controller modally.
            self.present(composeVC, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        // Check the result or perform other tasks.
        
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = Data.userName
        emailLabel.text = Data.userEmail
        teamNameLabel.text = Data.userTeam
        var activeRecs = 0
        var callBacks = 0
        for rec in Data.allRecs {
            if rec.status == .Active {
                activeRecs += 1
            } else if rec.status == .CallBacks {
                callBacks += 1
            }
        }
        recStatsLabel.text = "Active Recs: \(activeRecs), Call Backs: \(callBacks)"
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var recStatsLabel: UILabel!
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    //======================== OUTLETS =============================
    

    @IBAction func logout(_ sender: Any) {
        //print(Auth.auth() != nil)
        
        do {
            try Auth.auth().signOut()
            Data.clearVariables()
            performSegue(withIdentifier: "logout", sender: self)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    
    
    @IBAction func textTriggered(_ sender: Any) {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "Hi Joe, "
            controller.recipients = ["2017396630"]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func emailTriggered(_ sender: Any) {
        sendEmail()
    }
    
    private func showSettingsAlert() {
        let alert = UIAlertController(title: nil, message: "queue requires access to Contacts to proceed. Would you like to open settings and grant permission to contacts?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { action in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
            //completionHandler(false)
        })
        present(alert, animated: true)
    }
    
    func enumerateAndSegue() {
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactNoteKey]
        let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
        let store = CNContactStore()
        do {
            try store.enumerateContacts(with: request, usingBlock: { (importedContact, stopPointer) in
                let last = importedContact.familyName
                let first = importedContact.givenName
                let notes = importedContact.note
                var number: String = importedContact.phoneNumbers.first?.value.stringValue ?? ""
                number.removeAll(where: {$0 == "-"})
                number.removeAll(where: {$0 == ")"})
                number.removeAll(where: {$0 == "("})
                number.removeAll(where: {$0 == "+"})
                number.removeAll(where: {$0 == " "})
                if number.count == 11 {
                    number.remove(at: number.startIndex)
                }
                if number.count == 10 {
                    var shouldAppend = true
                    for rec in Data.allRecs {
                        if rec.phoneNumber == number {
                            shouldAppend = false
                        }
                    }
                    if shouldAppend {
                        Data.allContacts.append(Contact(firstName: first, lastName: last, phoneNumber: number, notes: notes))
                    }
                }
            })
            Data.allContacts.sort(by: {$0.getSortName() < $1.getSortName()})
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "importContacts", sender: self)
            }
        }
        catch let err {
            print("error enumerating contacts", err)
            let alert = UIAlertController(title: "oops!", message: "there was an error fetching contacts", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default) { action in
                //completionHandler(false)
            })
            present(alert, animated: true)
        }
    }
    
    func requestAccess() {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, err) in
            if let error = err {
                print("error requesting contacts:", error)
            }
            if granted {
                self.enumerateAndSegue()
            } else {
                DispatchQueue.main.async {
                    self.showSettingsAlert()
                }
            }
        }
    }
    
    @IBAction func importContactsTriggered(_ sender: Any) {
        Data.allContacts = []
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            enumerateAndSegue()
        case .denied:
            showSettingsAlert()
        case .notDetermined, .restricted:
            requestAccess()
        }
    }
    
}
