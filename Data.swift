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
    
    static func == (lhs: Status, rhs: Status) -> Bool {
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

enum EntryType {
    case Upload
    case Declined
    case Unreached
    case CallBack
    case Booked
    case SentText
    case Rescheduled
    case Cancelled
}

extension UIViewController {
    class func displaySpinner(onView : UIView) -> UIView {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        return spinnerView
    }
    
    class func removeSpinner(spinner :UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
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
            return "Yesterday"
        } else if Int(dateDay)! - 1 == Int(currentDay)! && dateMonth == currentMonth && dateYear == currentYear {
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
    static func clearVariables() {
        homeIsDashboard = true
        nextEventTag = 0
        nextRecTag = 0
        uid = ""
        userName = ""
        userEmail = ""
        userTeam = ""
        allRecs = []
        currentGroup = .Active
        filter = .ByRef
        filteredRecs = [[]]
        allEvents = []
        amountQueued = 0
        thisRec = nil
        sectionHeaders = []
        upcomingEvents = []
        pastEvents = []
        callQueue = []
        dialJamCallsMade = 0
        dialJamBooked = 0
        dialJamPhoneNumber = ""
        allContacts = []
    }
    static var allContacts: [Contact] = []
    static var dialJamCallsMade = 0
    static var dialJamBooked = 0
    static var dialJamPhoneNumber : String = ""
    static var homeIsDashboard = true
    static var nextEventTag = 0
    static var nextRecTag = 0
    static var firstSignIn = true
    static var uid = ""
    static var userName: String = ""
    static var userTeam: String = ""
    static var userEmail: String = ""
    static var allRecs : [Rec] = []
    static var currentGroup : Status = .Active
    static var filteredRecs : [[Rec]] = [[]]
    static var callQueue : [Rec] = []
    static var sectionHeaders : [String] = []
    static var filter : Filter = .ByRef
    static var allEvents : [Event] = []
    static var pastEvents : [Event] = []
    static var upcomingEvents: [Event] = []
    static let defaultBlue = UIColor.init(red: 0.0, green: 122 / 255.0, blue: 1.0, alpha: 1.0)
    static let red = UIColor.init(red: 1.0, green: 82 / 255.0, blue: 84 / 255.0, alpha: 1.0)
    static let blue = UIColor.init(red: 51 / 255.0, green: 109 / 255.0, blue: 153 / 255.0, alpha: 1.0)
    static let beige = UIColor.init(red: 242 / 255.0, green: 242 / 255.0, blue: 230 / 255.0, alpha: 1.0)
    static let lightBlue = UIColor.init(red: 169 / 255.0, green: 206 / 255.0, blue: 245 / 255.0, alpha: 1.0)
    static var amountQueued : Int = 0
    static var thisRec : Rec?
    
    static func callsToGo() -> Int {
        var callsToday = 0
        refreshEventSorting()
        for event in pastEvents {
            if event.rec == nil && event.date.getProperDescription() == "Today" {
                let callsString: String = String(event.summary.split(separator: " ")[0])
                callsToday += Int(callsString)!
            } else if event.date.getProperDescription() != "Today" {
                break
            }
        }
        return 10 - callsToday
    }
    
    static func bookPercentage() -> Float {
        var answers = 0
        var booked = 0
        for rec in allRecs {
            answers += rec.numAnswers
            for entry in rec.getEntries() {
                if entry.type == .Booked {
                    booked += 1
                }
            }
        }
        let ans = Float(Double(booked) / Double(answers))
        if ans.isNaN || ans.isInfinite {
            return 0.0
        } else {
            return ans
        }
    }
    
    static func streak() -> Int {
        let now = Date()
        let time = now.getTime()
        var secondsSinceMidnight: Double = 0
        if time[time.index(time.endIndex, offsetBy: -2)] == "p" {
            secondsSinceMidnight += 12 * 3600
        }
        let split = time.split(separator: ":")
        let hour = Double(String(split[0]))!
        var minutesString = String(split[1])
        minutesString.remove(at: minutesString.index(before: minutesString.endIndex))
        minutesString.remove(at: minutesString.index(before: minutesString.endIndex))
        let minutes = Double(minutesString)!
        secondsSinceMidnight += hour * 3600
        secondsSinceMidnight += minutes * 60
        let midnight = Date(timeInterval: -secondsSinceMidnight, since: now)
        Data.refreshEventSorting()
        let oneDay : Double = 86400
        var upper = midnight
        var lower = midnight - oneDay
        var streakIsAlive = true
        var streak : Int = 0
        while streakIsAlive {
            var calls = 0
            for event in pastEvents {
                if event.rec == nil && lower < event.date && event.date < upper {
                    let callsString: String = String(event.summary.split(separator: " ")[0])
                    calls += Int(callsString)!
                }
            }
            if calls >= 10 {
                streak += 1
            } else {
                streakIsAlive = false
            }
            upper -= oneDay
            lower -= oneDay
        }
        //find out if the person has made ten calls today
        upper = midnight + oneDay
        lower = midnight
        var calls = 0
        for event in pastEvents {
            if event.rec == nil && lower < event.date && event.date < upper {
                let callsString: String = String(event.summary.split(separator: " ")[0])
                calls += Int(callsString)!
            }
        }
        if calls >= 10 {
            streak += 1
        }
        return streak
    }
    
    static func callsToDemos() -> Double {
        var calls = 0
        var booked = 0
        for rec in allRecs {
            calls += rec.numCalls
            for entry in rec.getEntries() {
                if entry.type == .Booked {
                    booked += 1
                }
            }
        }
        return Double(calls) / Double(booked)
    }
    
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
        upcomingEvents.sort(by: {$0.date < $1.date})
        pastEvents.sort(by: {$0.date > $1.date})
    }
    
    static func refreshRatings() {
        for rec in allRecs {
            var hasFirstName = false
            var hasLastName = false
            if let first = rec.firstName {
                if first != "" {
                    hasFirstName = true
                }
            }
            if let last = rec.lastName {
                if last != "" {
                    hasLastName = true
                }
            }
            if rec.status != .Active || (!hasLastName && !hasFirstName) {
                rec.rating = -1000.0
            } else {
                rec.rating = 0.0
                if rec.referrer == nil {
                    rec.rating += 60.0
                } else if rec.referrer! == "" {
                    rec.rating += 60.0
                }
                if rec.starred {
                    rec.rating += 40.0
                }
                if rec.hot {
                    rec.rating += 40.0
                }
                var entries = rec.getEntries()
                entries.sort(by: {$0.date > $1.date})
                for entry in entries {
                    if entry.type == .CallBack {
                        let callBackDate = entry.nextEventDate!
                        let now = Date()
                        if callBackDate < now {
                            if now.timeIntervalSince1970 - callBackDate.timeIntervalSince1970 < 604300 {
                                rec.rating += 1000
                            }
                        }
                        break;
                    }
                }
                rec.rating -= min(Double(rec.numCalls - rec.numAnswers) * 2, 50)
            }
        }
        allRecs.sort(by: {$0.rating > $1.rating})
    }
    
    static func refreshStatusesAndHotness() {
        for rec in allRecs {
            let (status, isHot) = getStatusAndIsHot(fromEntries: rec.getEntries())
            rec.status = status
            rec.hot = isHot
        }
    }
    
    static func refreshFilter() {
        refreshStatusesAndHotness()
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
            var shouldAddUnkown = false
            for rec in allRecs {
                if rec.status == currentGroup {
                    let thisRef = rec.referrer ?? ""
                    if thisRef == "" {
                        var hasFirstName = false
                        var hasLastName = false
                        if let first = rec.firstName {
                            if first != "" {
                                hasFirstName = true
                            }
                        }
                        if let last = rec.lastName {
                            if last != "" {
                                hasLastName = true
                            }
                        }
                        if hasLastName || hasFirstName {
                            shouldAddPersonalContacts = true
                        } else {
                            shouldAddUnkown = true
                        }
                    }
                    else if !sectionHeaders.contains(thisRef) {
                        sectionHeaders.append(thisRef)
                    }
                }
            }
            sectionHeaders.sort()
            if shouldAddPersonalContacts {
                sectionHeaders.insert("Personal Contacts", at: 0)
            }
            if shouldAddUnkown {
                sectionHeaders.append("Unkown")
            }
            for _ in 0...sectionHeaders.count {
                filteredRecs.append([])
            }
            for rec in allRecs {
                if rec.status == currentGroup {
                    let thisRef = rec.referrer ?? ""
                    var hasFirstName = false
                    var hasLastName = false
                    if let first = rec.firstName {
                        if first != "" {
                            hasFirstName = true
                        }
                    }
                    if let last = rec.lastName {
                        if last != "" {
                            hasLastName = true
                        }
                    }
                    let index: Int
                    if thisRef == "" {
                        if hasFirstName || hasLastName {
                            index = 0
                        } else {
                            index = sectionHeaders.count - 1
                        }
                    } else {
                        index = sectionHeaders.index(of: thisRef)!
                    }
                    filteredRecs[index].append(rec)
                }
            }
            for var recList in filteredRecs {
                recList.sort(by: Rec.alphaFirstSort(lhs:rhs:))
            }
        }
    }
    
    static func getStatusAndIsHot(fromEntries: [Entry]) -> (Status, Bool) {
        var entries = fromEntries
        entries.sort(by: {$0.date > $1.date})
        for entry in entries {
            switch entry.type {
            case .Booked:
                return (.Booked, false)
            case .Cancelled:
                return (.Active, true)
            case .Rescheduled:
                return (.Booked, false)
            case .CallBack:
                let callBackDate = entry.nextEventDate!
                let now = Date()
                if callBackDate < now {
                    if now.timeIntervalSince1970 - callBackDate.timeIntervalSince1970 > 604300 {
                        return (.Active, false)
                    } else {
                        return (.Active, true)
                    }
                } else {
                    return (.CallBacks, false)
                }
            case .Declined:
                return (.Declined, false)
            case .Upload:
                if Date().timeIntervalSince1970 - entry.date.timeIntervalSince1970 > 604300 {
                    return (.Active, false)
                } else {
                    return (.Active, true)
                }
            case .Unreached:
                continue
            case .SentText:
                continue
            }
        }
        return (.Active, false)
    }
    
    static func deleteEvent(event: Event) {
        allEvents.remove(at: allEvents.index(of: event)!)
        QueryManager.deleteEvent(ID: event.ID)
    }
    
    static func newEvent(event: Event) {
        nextEventTag += 1
        allEvents.append(event)
        if let rec = event.rec {
            QueryManager.saveNewEvent(summary: event.summary, date: event.date, recID: rec.ID)
        } else {
            QueryManager.saveNewEvent(summary: event.summary, date: event.date, recID: "")
        }
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
