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
    init(imageFile: String, date: Date, entryOutcome: String) {
        self.imageFile = imageFile
        self.date = date
        self.entryOutcome = entryOutcome
    }
}
