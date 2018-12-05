//
//  Data.swift
//  queue
//
//  Created by Joseph Jordan on 11/25/18.
//  Copyright © 2018 queue. All rights reserved.
//

import UIKit

enum Status : Equatable {
    case Active
    case Booked
    case CallBacks
    case Declined
    
    static func ==(lhs: Status, rhs: Status) -> Bool {
        switch (lhs, rhs) {
        case (.Active, .Active):
            return true
        case (.Booked, .Booked):
            return true
        case (.CallBacks, .CallBacks):
            return true
        case (.Declined, .Declined):
            return true
        default:
            return false
        }
    }
}

extension Date {
    func getProperDescription() -> String {
        var splitter = self.description(with: Locale.current).split(separator: " ")
        let dateDay = String(splitter[2]).dropLast()
        let dateYear = splitter[3]
        let dateMonth = splitter[1]
        splitter = Date().description(with: Locale.current).split(separator: " ")
        let currentDay = String(splitter[2]).dropLast()
        let currentMonth = splitter[1]
        let currentYear = splitter[3]
        if dateDay == currentDay && dateMonth == currentMonth && dateYear == currentYear {
            return "Today"
        } else if Int(dateDay)! + 1 == Int(currentDay)! && dateMonth == currentMonth && dateYear == currentYear {
            return "Tomorrow"
        } else {
            return dateMonth + " " + dateDay
        }
    }
    
    func getTime() -> String {
        var splitter = self.description(with: Locale.current).split(separator: " ")
        let end =  String(splitter[6])
        splitter = String(splitter[5]).split(separator: ":")
        return String(splitter[0]) + ":" + String(splitter[1]) + end.lowercased()
    }
}

enum Filter : Equatable {
    case AlphaFirst //alphabetical by first name
    case AlphaLast  //alphabetical by last name
    case ByRef      //alphabetical by referred
    
    static func ==(lhs: Filter, rhs: Filter) -> Bool {
        switch (lhs, rhs) {
        case (.AlphaFirst, .AlphaFirst):
            return true
        case (.AlphaLast, .AlphaLast):
            return true
        case (.ByRef, .ByRef):
            return true
        default:
            return false
        }
    }
}

class Data: NSObject {
    static var userName: String = "Joseph Jordan"
    static var userTeam: String = "Somerset Swat"
    static var userEmail: String = ""
    static var allRecs : [Rec] = []
    static var currentGroup : Status = .Active
    static var filteredRecs : [[Rec]] = [[]]
    static var callQueue : [Rec] = []
    static var sectionHeaders : [String] = []
    static var filter : Filter = .AlphaLast
    static var allEvents : [Event] = []
    static var pastEvents : [Event] = []
    static var upcomingEvents: [Event] = []
    static let red = UIColor.init(red: 1.0, green: 82 / 255.0, blue: 84 / 255.0, alpha: 1.0)
    static let blue = UIColor.init(red: 51 / 255.0, green: 109 / 255.0, blue: 153 / 255.0, alpha: 1.0)
    static let beige = UIColor.init(red: 242 / 255.0, green: 242 / 255.0, blue: 230 / 255.0, alpha: 1.0)
    static let lightBlue = UIColor.init(red: 169 / 255.0, green: 206 / 255.0, blue: 245 / 255.0, alpha: 1.0)
    static var amountQueued : Int = 0
    
    static func refreshEventSorting() {
        let now = Date()
        pastEvents = []
        upcomingEvents = []
        for event in allEvents {
            if event.date < now {
                pastEvents.append(event)
            } else {
                upcomingEvents.append(event)
            }
        }
    }
    
    static func refreshFilter() {
        filteredRecs = [[]]
        sectionHeaders = []
        switch filter {
        case .AlphaLast:
            for rec in allRecs {
                if rec.status == currentGroup {
                    filteredRecs[0].append(rec)
                }
            }
            filteredRecs[0].sort(by: Rec.alphaLastSort(lhs:rhs:))
        case .AlphaFirst:
            for rec in allRecs {
                if rec.status == currentGroup {
                    filteredRecs[0].append(rec)
                }
            }
            filteredRecs[0].sort(by: Rec.alphaFirstSort(lhs:rhs:))
        case .ByRef:
            var shouldAddPersonalContacts = false
            for rec in allRecs {
                let thisRef = rec.referrer ?? ""
                if thisRef == "" {
                    shouldAddPersonalContacts = true
                }
                else if !sectionHeaders.contains(thisRef) {
                    sectionHeaders.append(thisRef)
                }
            }
            sectionHeaders.sort()
            if shouldAddPersonalContacts {
                sectionHeaders.insert("Personal Contacts", at: 0)
            }
            for _ in 0...sectionHeaders.count {
                filteredRecs.append([])
            }
            for rec in allRecs {
                let thisRef = rec.referrer ?? ""
                let index = sectionHeaders.index(of: thisRef) ?? 0
                filteredRecs[index].append(rec)
            }
            for var recList in filteredRecs {
                recList.sort(by: Rec.alphaFirstSort(lhs:rhs:))
            }
        }
    }
    static let entries = [
            Entry(imageFile: "upload icon.png", date: Date.distantPast, entryOutcome: "Uploaded"),
            Entry(imageFile: "refresh icon.png", date: Date.distantPast, entryOutcome: "Call Back"),
            Entry(imageFile: "x icon.png", date: Date.distantPast, entryOutcome: "Declined"),
            Entry(imageFile: "check mark icon.png", date: Date.distantPast, entryOutcome: "Demo Booked"),
            Entry(imageFile: "phone icon.png", date: Date.distantPast, entryOutcome: "Unreached"), Entry(imageFile: "refresh icon.png", date: Date.distantPast, entryOutcome: "Call Back"), Entry(imageFile: "refresh icon.png", date: Date.distantPast, entryOutcome: "Call Back"), Entry(imageFile: "refresh icon.png", date: Date(), entryOutcome: "Call Back"), Entry(imageFile: "refresh icon.png", date: Date(), entryOutcome: "Call Back")]
    
    static func prepareTestValues() {
        allEvents = [Event(date: Date.distantFuture, summary: "Demo", rec: Rec(firstName: "", lastName: "", referrer: "Bob Marley", note: "", phoneNumber: "2017396630", starred: true, entries: [])), Event(date: Date.distantPast, summary: "40 calls, 4 demos"), Event(date: Date.distantFuture, summary: "Call Back", rec: Rec(firstName: "Abigail", lastName: "Zest", referrer: nil, note: "my mom is the best mom ever. She is a preschool teacher at the lindgren school. She has an MBA from St Johns University in Queens. She is the best.", phoneNumber: "2013146098", starred: true, entries: entries)), Event(date: Date.distantPast, summary: "40 calls, 4 demos"), Event(date: Date.distantPast, summary: "3 calls, 100 demos"), Event(date: Date.distantPast, summary: "3000 calls, 100 demos")]
        allRecs = [Rec(firstName: "Abigail", lastName: "Zest", referrer: nil, note: "my mom is the best mom ever. She is a preschool teacher at the lindgren school. She has an MBA from St Johns University in Queens. She is the best.", phoneNumber: "2013146098", starred: true, entries: entries), Rec(firstName: "Barry", lastName: "Yolanda", referrer: nil, note: "padre", phoneNumber: "2014506073", starred: true, entries: [Entry(imageFile: "upload icon.png", date: Date(), entryOutcome: "Uploaded")]), Rec(firstName: "Corey", lastName: "XXX", referrer: "Jeff Goldstein", note: "owns a yacht", phoneNumber: "2011111111", starred: false, entries: entries), Rec(firstName: "Doug", lastName: "Wellenkamp", referrer: "Steve", note: "owns a yacht", phoneNumber: "2011111111", starred: false, entries: entries), Rec(firstName: "Ed", lastName: "Viper", referrer: "Guy", note: "owns a yacht", phoneNumber: "2011111111", starred: false, entries: entries), Rec(firstName: "Fred", lastName: "Underwear", referrer: "Guy", note: "owns a yacht", phoneNumber: "2011111111", starred: false, entries: entries), Rec(firstName: "Greg", lastName: "Tucker", referrer: "Stave", note: "owns a yacht", phoneNumber: "2011111111", starred: false, entries: entries), Rec(firstName: "Hal", lastName: "Schumacher", referrer: "Andrew", note: "owns a yacht", phoneNumber: "2011111111", starred: false, entries: entries), Rec(firstName: "Ingrid", lastName: "Roth", referrer: "James", note: "owns a yacht", phoneNumber: "2011111111", starred: false, entries: entries), Rec(firstName: "Joseph", lastName: "Queue", referrer: "James", note: "owns a yacht", phoneNumber: "2011111111", starred: false, entries: entries), Rec(firstName: "Kristin", lastName: "Potter", referrer: "James", note: "owns a yacht", phoneNumber: "2011111111", starred: false, entries: entries), Rec(firstName: "Lou", lastName: "Barzallato", referrer: "Steve", note: "owns a yacht", phoneNumber: "2011111111", starred: false, entries: entries), Rec(firstName: nil, lastName: nil, referrer: "Steve", note: "owns a yacht", phoneNumber: "2011111111", starred: false, entries: entries)]
        }
    
    /*static func refreshSort() {
        switch filter {
        case .AlphaFirst:
            filteredRecs.sort(by: Rec.alphaFirstSort)
            for rec in filteredRecs {
                if let char = rec.firstName?.first {
                    let letter = String(char).uppercased()
                    if !sectionHeaders.contains(letter) {
                        sectionHeaders.append(letter)
                    }
                    continue
                }
                if let char = rec.lastName?.first {
                    let letter = String(char).uppercased()
                    if !sectionHeaders.contains(letter) {
                        sectionHeaders.append(letter)
                    }
                    continue
                }
                if !sectionHeaders.contains("?") {
                    sectionHeaders.append("?")
                }
            }
        case .AlphaLast:
            filteredRecs.sort(by: Rec.alphaLastSort)
            for rec in filteredRecs {
                if let char = rec.lastName?.first {
                    let letter = String(char).uppercased()
                    if !sectionHeaders.contains(letter) {
                        sectionHeaders.append(letter)
                    }
                    continue
                }
                if let char = rec.firstName?.first {
                    let letter = String(char).uppercased()
                    if !sectionHeaders.contains(letter) {
                        sectionHeaders.append(letter)
                    }
                    continue
                }
                if !sectionHeaders.contains("?") {
                    sectionHeaders.append("?")
                }
            }
        case .ByRef:
            filteredRecs.sort(by: Rec.byRefSort)
            for rec in filteredRecs {
                if let ref = rec.referrer {
                    if !sectionHeaders.contains(ref) {
                        sectionHeaders.append(ref)
                    }
                }
                if !sectionHeaders.contains("Personal Contacts") {
                    sectionHeaders.append("Personal Contacts")
                }
            }
        }
        sectionHeaders.sort()
        if sectionHeaders.contains("Personal Contacts") {
            sectionHeaders.remove(at: sectionHeaders.index(of: "Personal Contacts")!)
            sectionHeaders.insert("Personal Contacts", at: 0)
        }
        if sectionHeaders.contains("?") {
            sectionHeaders.remove(at: sectionHeaders.index(of: "?")!)
            sectionHeaders.append("?")
        }
    }*/
}
