//
//  Contact.swift
//  queue
//
//  Created by Joseph Jordan on 12/12/18.
//  Copyright © 2018 queue. All rights reserved.
//

import UIKit

class Contact: NSObject {
    let firstName: String
    let lastName: String
    let phoneNumber: String
    let notes: String
    var isSelected = false
    
    init(firstName: String, lastName: String, phoneNumber: String, notes: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.notes = notes
    }
    
    func getSortName() -> String {
        return firstName + lastName
    }
    
    func getDisplayName() -> String {
        return firstName + " " + lastName
    }
}
