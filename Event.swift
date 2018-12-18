//
//  Event.swift
//  queue
//
//  Created by Joseph Jordan on 12/1/18.
//  Copyright © 2018 queue. All rights reserved.
//

import UIKit

class Event: NSObject {
    var date : Date
    var summary : String
    var rec: Rec?
    var ID: String
    
    init(date: Date, summary: String, rec: Rec?, ID: String) {
        self.date = date
        self.summary = summary
        self.rec = rec
        self.ID = ID
    }
    
    init(date: Date, summary: String, ID: String) {
        self.date = date
        self.summary = summary
        self.ID = ID
    }
}
