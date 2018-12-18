//
//  Entry.swift
//  queue
//
//  Created by Joseph Jordan on 11/29/18.
//  Copyright © 2018 queue. All rights reserved.
//

import UIKit

class Entry: NSObject {
    let imageFile : String
    let date : Date
    let entryOutcome: String
    let nextEventDate : Date?
    let type : EntryType
    
    init(type: EntryType) {
        self.nextEventDate = nil
        self.date = Date()
        self.type = type
        switch type {
            case .Upload:
            imageFile = "upload icon.png"
            entryOutcome = "Uploaded"
            case .Declined:
            imageFile = "x icon.png"
            entryOutcome = "Declined"
            case .Unreached:
            imageFile = "phone icon.png"
            entryOutcome = "Unreached"
        case .SentText:
            imageFile = "text icon.png"
            entryOutcome = "Sent text"
        case .Cancelled:
            imageFile = "x icon.png"
            entryOutcome = "Cancelled"
        default:
            imageFile = "phone icon.png"
            entryOutcome = "Unreached"
        }
    }
    
    init(type: EntryType, nextEventDate: Date) {
        self.date = Date()
        self.nextEventDate = nextEventDate
        self.type = type
        switch type {
        case .Booked:
            self.entryOutcome = "Demo Booked for \(nextEventDate.getTime()) \(nextEventDate.getProperDescription())"
            self.imageFile = "check mark icon.png"
        case .Rescheduled:
            self.entryOutcome = "Rescheduled for \(nextEventDate.getTime()) \(nextEventDate.getProperDescription())"
            self.imageFile = "check mark icon.png"
        default:
            self.entryOutcome = "Call Back After \(nextEventDate.getTime()) \(nextEventDate.getProperDescription())"
            self.imageFile = "refresh icon.png"
        }
    }
    
    init(type: String, date: Date, followUpDate: Date?) {
        self.nextEventDate = followUpDate
        self.date = date
        switch type {
        case "upload":
            self.type = .Upload
            imageFile = "upload icon.png"
            entryOutcome = "Uploaded"
        case "decline":
            self.type = .Declined
            imageFile = "x icon.png"
            entryOutcome = "Declined"
        case "unreach":
            self.type = .Unreached
            imageFile = "phone icon.png"
            entryOutcome = "Unreached"
        case "callBack":
            self.type = .CallBack
            imageFile = "refresh icon.png"
            entryOutcome = "Call Back After \(followUpDate!.getTime()) \(followUpDate!.getProperDescription())"
        case "demo":
            self.type = .Booked
            imageFile = "check mark icon.png"
            entryOutcome = "Demo Booked for \(followUpDate!.getTime()) \(followUpDate!.getProperDescription())"
        case "sentText":
            self.type = .SentText
            imageFile = "text icon.png"
            entryOutcome = "Sent text"
        case "rescheduled":
            self.type = .Rescheduled
            entryOutcome = "Rescheduled for \(followUpDate!.getTime()) \(followUpDate!.getProperDescription())"
            imageFile = "check mark icon.png"
        case "cancelled":
            self.type = .Cancelled
            entryOutcome = "Demo cancelled"
            imageFile = "x icon.png"
        default:
            self.type = .Unreached
            imageFile = "phone icon.png"
            entryOutcome = "Unreached"
        }
    }

}
