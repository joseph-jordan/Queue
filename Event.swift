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
    
    init(date: Date, summary: String, rec: Rec?) {
        self.date = date
        self.summary = summary
        self.rec = rec
    }
    
    init(date: Date, summary: String) {
        self.date = date
        self.summary = summary
    }
}
