//
//  Call.swift
//  queue
//
//  Created by Joseph Jordan on 11/29/18.
//  Copyright © 2018 queue. All rights reserved.
//

import UIKit

class Call: NSObject {
    
    var date : String = ""
    var outcome : Status
    
    init(date: String, outcome: Status) {
        self.date = date
        self.outcome = outcome
    }

}
