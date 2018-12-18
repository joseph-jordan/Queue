//
//  ImportContactsViewController.swift
//  queue
//
//  Created by Joseph Jordan on 12/12/18.
//  Copyright © 2018 queue. All rights reserved.
//

import UIKit
import Contacts

class ImportContactsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var contactsToImport: [Contact] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        contactsTableView.delegate = self
        contactsTableView.dataSource = self
        statusLabel.text = "tap to begin"
        // Do any additional setup after loading the view.
    }
    
    //======================TABLE VIEW DELEGATION=====================
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Data.allContacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell") as! ContactTableViewCell
        let contact = Data.allContacts[indexPath.row]
        cell.titleLabel.text = contact.getDisplayName()
        if contact.isSelected {
            cell.backgroundColor = Data.lightBlue
        } else {
            cell.backgroundColor = UIColor.white
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = Data.allContacts[indexPath.row]
        contact.isSelected = !contact.isSelected
        if contact.isSelected {
            contactsToImport.append(contact)
        } else {
            contactsToImport.remove(at: contactsToImport.index(of: contact)!)
        }
        if contactsToImport.count == 0 {
            statusLabel.text = "tap to begin"
        } else if contactsToImport.count == 1 {
            statusLabel.text = "1 contact selected"
        } else {
            statusLabel.text = "\(contactsToImport.count) contacts selected"
        }
        contactsTableView.reloadData()
    }
    
    //======================OUTLETS=====================
    @IBOutlet weak var contactsTableView: UITableView!
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBAction func cancelTriggered(_ sender: Any) {
        Data.allContacts = []
        performSegue(withIdentifier: "backToSettings", sender: self)
    }
    
    @IBAction func importTriggered(_ sender: Any) {
        for contact in contactsToImport {
            contact.isSelected = false
            let _ = QueryManager.saveNewRec(firstName: contact.firstName, lastName: contact.lastName, referrer: nil, note: contact.notes, phoneNumber: contact.phoneNumber, starred: false)
        }
        contactsToImport = []
        Data.allContacts = []
        performSegue(withIdentifier: "backToSettings", sender: self)
    }
    
    @IBAction func clearTriggered(_ sender: Any) {
        for contact in contactsToImport {
            contact.isSelected = false
        }
        contactsToImport = []
        statusLabel.text = "tap to begin"
        contactsTableView.reloadData()
    }
}
