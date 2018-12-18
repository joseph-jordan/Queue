//
//  QueryManager.swift
//  queue
//
//  Created by Joseph Jordan on 12/9/18.
//  Copyright © 2018 queue. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class QueryManager: NSObject {
    static let ref = Database.database().reference()
    
    static func createUser(uid: String, teamID: String, name: String, phoneNumber: String, completion: @escaping (() -> Void)) {
        Data.uid = uid
        ref.child("users").child(uid).child("teamID").setValue(teamID)
        ref.child("users").child(uid).child("name").setValue(name)
        ref.child("users").child(uid).child("phoneNumber").setValue(phoneNumber)
        ref.child("users").child(uid).child("nextRecTag").setValue("0")
        ref.child("users").child(uid).child("nextEventTag").setValue("0")
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let repTag = snapshot.childSnapshot(forPath: "teams").childSnapshot(forPath: teamID).childSnapshot(forPath: "nextRepTag").value as? String {
                ref.child("teams").child(teamID).child("reps").child(repTag).setValue(uid)
                ref.child("teams").child(teamID).child("nextRepTag").setValue(String(Int(repTag)! + 1))
                Data.userName = name
                ref.observeSingleEvent(of: .value) { (snapshot) in
                    Data.userTeam = snapshot.childSnapshot(forPath: "teams").childSnapshot(forPath: teamID).childSnapshot(forPath: "teamName").value as! String
                    completion()
                }
            }
        }
    }
    
    static func appendEntryToRec(recID: String, entry: Entry) {
        let recNode = ref.child("users").child(Data.uid).child("recs").child(String(recID))
        ref.observeSingleEvent(of: .value) { (snapshot) in
            let newEntryNum = snapshot.childSnapshot(forPath: "users").childSnapshot(forPath: Data.uid).childSnapshot(forPath: "recs").childSnapshot(forPath: recID).childSnapshot(forPath: "nextEntryTag").value as! String
            recNode.child("nextEntryTag").setValue(String(Int(newEntryNum)! + 1))
            recNode.child("entries").child(newEntryNum).child("dateCreated").setValue(String(entry.date.timeIntervalSince1970))
            if let followUpDate = entry.nextEventDate {
                recNode.child("entries").child(newEntryNum).child("followUpDate").setValue(String(followUpDate.timeIntervalSince1970))
            } else {
                recNode.child("entries").child(newEntryNum).child("followUpDate").setValue("")
            }
            let type: String
            switch entry.type {
            case .CallBack:
                type = "callBack"
            case .Booked:
                type = "demo"
            case .Upload:
                type = "upload"
            case .Declined:
                type = "decline"
            case .Unreached:
                type = "unreach"
            case .SentText:
                type = "sentText"
            case .Cancelled:
                type = "cancelled"
            case .Rescheduled:
                type = "rescheduled"
            }
            recNode.child("entries").child(newEntryNum).child("type").setValue(type)
            recNode.child("entries").child(newEntryNum).child("deleted").setValue("false")
        }
    }
    
    static func updateRecVariable(withID: String, forPath: String, value: String) {
        ref.child("users").child(Data.uid).child("recs").child(withID).child(forPath).setValue(value)
    }
    
    static func deleteEvent(ID: String) {
        ref.child("users").child(Data.uid).child("events").child(ID).child("deleted").setValue("true")
    }
    
    static func saveNewEvent(summary: String, date: Date, recID: String) {
        ref.observeSingleEvent(of: .value) { (snapshot) in
            let nextEventTag = snapshot.childSnapshot(forPath: "users").childSnapshot(forPath: Data.uid).childSnapshot(forPath: "nextEventTag").value as! String
            
            let node = ref.child("users").child(Data.uid).child("events").child(nextEventTag)
            node.child("summary").setValue(summary)
            node.child("date").setValue(String(date.timeIntervalSince1970))
            node.child("rec").setValue(recID)
            node.child("deleted").setValue("false")
            ref.child("users").child(Data.uid).child("nextEventTag").setValue(String(Int(nextEventTag)! + 1))
        }
        
    }
    
    static func saveNewRec(firstName : String?, lastName: String?, referrer : String?, note : String?, phoneNumber : String, starred: Bool) -> Rec {
        let now = Date()
        let newRec = Rec(firstName: firstName, lastName: lastName, referrer: referrer, note: note, phoneNumber: phoneNumber, starred: starred, entries: [Entry(type: "upload", date: Date(), followUpDate: nil)], ID: String(Data.nextRecTag), status: .Active)
        newRec.hot = true
        Data.allRecs.append(newRec)
        let node = ref.child("users").child(Data.uid).child("recs").child(String(Data.nextRecTag))
        node.child("firstName").setValue(firstName ?? "")
        node.child("lastName").setValue(lastName ?? "")
        node.child("phoneNumber").setValue(phoneNumber)
        node.child("referrer").setValue(referrer ?? "")
        node.child("notes").setValue(note ?? "")
        node.child("starred").setValue(String(starred))
        node.child("deleted").setValue("false")
        node.child("nextEntryTag").setValue("1")
        node.child("entries").child("0").child("dateCreated").setValue(String(now.timeIntervalSince1970))
        node.child("entries").child("0").child("followUpDate").setValue("")
        node.child("entries").child("0").child("type").setValue("upload")
        node.child("entries").child("0").child("deleted").setValue("false")
        Data.nextRecTag += 1
        ref.child("users").child(Data.uid).child("nextRecTag").setValue(String(Data.nextRecTag))
        return newRec
    }
    
    static func loadUserData(uid: String, completion: @escaping (() -> Void)) {
        Data.uid = uid
        ref.observeSingleEvent(of: .value) { (snapshot) in
            var teamID = snapshot.childSnapshot(forPath: "users").childSnapshot(forPath: uid).childSnapshot(forPath: "teamID").value as! String
            teamID = String(Int(teamID)!)
            Data.userName = snapshot.childSnapshot(forPath: "users").childSnapshot(forPath: uid).childSnapshot(forPath: "name").value as! String
            Data.userTeam = snapshot.childSnapshot(forPath: "teams").childSnapshot(forPath: teamID).childSnapshot(forPath: "teamName").value as! String
            let recSnap = snapshot.childSnapshot(forPath: "users").childSnapshot(forPath: uid).childSnapshot(forPath: "recs")
            let numRecs = Int(snapshot.childSnapshot(forPath: "users").childSnapshot(forPath: uid).childSnapshot(forPath: "nextRecTag").value as! String)!
            let numEvents = Int(snapshot.childSnapshot(forPath: "users").childSnapshot(forPath: uid).childSnapshot(forPath: "nextEventTag").value as! String)!
            Data.nextRecTag = numRecs
            Data.nextEventTag = numEvents
            for i in 0..<numRecs {
                let thisRec = recSnap.childSnapshot(forPath: String(i))
                if Bool(thisRec.childSnapshot(forPath: "deleted").value as! String)! {
                    continue
                }
                let firstName = thisRec.childSnapshot(forPath: "firstName").value as! String
                let lastName = thisRec.childSnapshot(forPath: "lastName").value as! String
                let referrer = thisRec.childSnapshot(forPath: "referrer").value as! String
                let ID = String(i)
                let notes = thisRec.childSnapshot(forPath: "notes").value as! String
                let phoneNumber = thisRec.childSnapshot(forPath: "phoneNumber").value as! String
                let nextEntryTag = Int(thisRec.childSnapshot(forPath: "nextEntryTag").value as! String)!
                let starred = Bool(thisRec.childSnapshot(forPath: "starred").value as! String)!
                var entries: [Entry] = []
                for j in 0..<nextEntryTag {
                    let thisEntrySnap = thisRec.childSnapshot(forPath: "entries").childSnapshot(forPath: String(j))
                    if Bool(thisEntrySnap.childSnapshot(forPath: "deleted").value as! String)! {
                        continue
                    }
                    let dateCreated = Double(thisEntrySnap.childSnapshot(forPath: "dateCreated").value as! String)!
                    let entryType = thisEntrySnap.childSnapshot(forPath: "type").value as! String
                    let followUpDate = thisEntrySnap.childSnapshot(forPath: "followUpDate").value as! String
                    if followUpDate != "" {
                        entries.append(Entry(type: entryType, date: Date(timeIntervalSince1970: TimeInterval(exactly: dateCreated)!), followUpDate: Date(timeIntervalSince1970: TimeInterval(exactly: Double(followUpDate)!)!)))
                    } else {
                        entries.append(Entry(type: entryType, date: Date(timeIntervalSince1970: TimeInterval(exactly: dateCreated)!), followUpDate: nil))
                    }
                }
                entries.sort(by: { $0.date > $1.date })
                let (status, isHot) = Data.getStatusAndIsHot(fromEntries: entries)
                let newRec = Rec(firstName: firstName, lastName: lastName, referrer: referrer, note: notes, phoneNumber: phoneNumber, starred: starred, entries: entries, ID: ID, status: status)
                newRec.hot = isHot
                Data.allRecs.append(newRec)
                
            }
            for i in 0..<numEvents {
                let thisEvent = snapshot.childSnapshot(forPath: "users").childSnapshot(forPath: uid).childSnapshot(forPath: "events").childSnapshot(forPath: String(i))
                if Bool(thisEvent.childSnapshot(forPath: "deleted").value as! String)! {
                    continue
                }
                let summary = thisEvent.childSnapshot(forPath: "summary").value as! String
                let date = Date(timeIntervalSince1970: TimeInterval(exactly: Double(thisEvent.childSnapshot(forPath: "date").value as! String)!)!)
                let eventRecID = thisEvent.childSnapshot(forPath: "rec").value as! String
                if eventRecID == "" {
                    Data.allEvents.append(Event(date: date, summary: summary, ID: String(i)))
                } else {
                    for rec in Data.allRecs {
                        if rec.ID == eventRecID {
                            Data.allEvents.append(Event(date: date, summary: summary, rec: rec, ID: String(i)))
                            break
                        }
                    }
                }
            }
            completion()
        }
    }
}
