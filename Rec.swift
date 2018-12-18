//
//  Rec.swift
//  queue
//
//  Created by Joseph Jordan on 11/28/18.
//  Copyright © 2018 queue. All rights reserved.
//

import UIKit
//import Firebase

class Rec: NSObject {
    
    var firstName : String?
    var lastName : String?
    var referrer : String?
    var phoneNumber : String
    var note: String?
    var isQueued = false
    var ID : String
    var status: Status = .Active
    var starred: Bool
    var hot: Bool = false
    var isExpanded: Bool = false
    private var entries: [Entry] = []
    var numCalls : Int = 0
    var numAnswers : Int = 0
    var rating : Double = 0.0
    
    init(firstName : String?, lastName: String?, referrer : String?, note : String?, phoneNumber : String, starred: Bool, entries : [Entry], ID: String, status: Status) {
        self.status = status
        self.ID = ID
        self.firstName = firstName
        self.lastName = lastName
        if let name = firstName {
            if name == "" {
                self.firstName = nil
            }
        }
        if let name = lastName {
            if name == "" {
                self.lastName = nil
            }
        }
        if let name = referrer {
            if name == "" {
                self.referrer = nil
            }
        }
        self.referrer = referrer
        self.note = note ?? ""
        self.phoneNumber = phoneNumber
        //self.ID = ID
        self.starred = starred
        for entry in entries {
            switch entry.type {
            case .Unreached:
                numCalls += 1
            case .Booked, .CallBack, .Declined:
                numAnswers += 1
                numCalls += 1
            default:
                break;
            }
        }
        self.entries = entries
    }
    
    func getEntry(index : Int) -> Entry{
        return entries[index]
    }
    
    func getEntries() -> [Entry] {
        return entries
    }
    
    func appendEntry(entry: Entry) {
        switch entry.type {
        case .Unreached:
            numCalls += 1
        case .Booked, .CallBack, .Declined:
            numAnswers += 1
            numCalls += 1
        default:
            break;
        }
        entries.insert(entry, at: 0)
        QueryManager.appendEntryToRec(recID: self.ID, entry: entry)
    }
    
    func getFullName() -> String {
        let first = firstName ?? ""
        let last = lastName ?? ""
        if first == "" && last == "" {
            return phoneDescription()
        } else if first == ""{
            return last
        } else {
            return first + " " + last
        }
    }
    
    func getName(priorityIsLastName : Bool) -> String? {
        if priorityIsLastName {
            switch (firstName, lastName){
            case (_, .some(let last)):
                return last
            case (.some(let first), .none):
                return first
            case (.none, .none):
                return nil
            }
        } else {
            switch (firstName, lastName){
            case (.some(let first), _):
                return first
            case (.none, .some(let last)):
                return last
            case (.none, .none):
                return nil
            }
        }
    }
    
    static func alphaFirstSort(lhs: Rec, rhs: Rec) -> Bool {
        switch (lhs.getName(priorityIsLastName: false), rhs.getName(priorityIsLastName: false)) {
        case (.none, .none):
            return lhs.phoneNumber < lhs.phoneNumber
        case(.some(_), .none):
            return true
        case(.none, .some(_)):
            return false
        case(.some(let l), .some(let r)):
            return l < r
        }
    }
    
    static func alphaLastSort(lhs: Rec, rhs: Rec) -> Bool {
        switch (lhs.getName(priorityIsLastName: true), rhs.getName(priorityIsLastName: true)) {
        case (.none, .none):
            return lhs.phoneNumber < lhs.phoneNumber
        case (.some(_), .none):
            return true
        case (.none, .some(_)):
            return false
        case (.some(let l), .some(let r)):
            return l < r
        }
    }
    
    static func byRefSort(lhs: Rec, rhs: Rec) -> Bool {
        switch (lhs.referrer, rhs.referrer) {
        case (.none, .none):
            return alphaLastSort(lhs: lhs, rhs: rhs)
        case (.some(_), .none):
            return false
        case (.none, .some(_)):
            return true
        case (.some(let l), .some(let r)):
            return l < r
        }
    }
    
    func phoneDescription() -> String {
        var str = phoneNumber
        str.insert("-", at: str.index(str.startIndex, offsetBy: 6))
        str.insert(" ", at: str.index(str.startIndex, offsetBy: 3))
        str.insert(")", at: str.index(str.startIndex, offsetBy: 3))
        str.insert("(", at: str.startIndex)
        return str
    }
    
    func sortEntries() {
        entries.sort(by: {$0.date > $1.date})
    }
    
    /*static var alphaLastSort: (Rec, Rec) -> Bool = {$0.lastName < $1.lastName}
    static var byRefSort : (Rec, Rec) -> Bool = {lhs, rhs in
        switch (lhs.referrer, rhs.referrer) {
        case (.none, .none):
            return lhs.lastName < rhs.lastName
        case (.none, .some(_)):
            return true
        case (.some(_), .none):
            return false
        case (.some(let rec1), .some(let rec2)):
            return rec1.lastName < rec2.lastName
        }
    }*/
    
    /*func updateStatus(newStatus: String) {
        if self.status == newStatus {
            return
        } else {
            Database.database().reference().child("reps").child(user).child(self.ID!).child("status").setValue(newStatus)
            
            if newStatus == "" || newStatus == "active" {
                recs.append(self)
            } else if newStatus == "declined" {
                declined.append(self)
            } else if newStatus == "booked" {
                booked.append(self)
            } else {
                deleted.append(self)
            }
            
            if status == "" || status == "active" {
                recs.remove(at: recs.index(of: self)!)
            } else if status == "declined" {
                declined.remove(at: declined.index(of: self)!)
            } else if status == "booked" {
                booked.remove(at: booked.index(of: self)!)
            } else {
                deleted.remove(at: deleted.index(of: self)!)
            }
            status = newStatus
        }
    }*/
}
