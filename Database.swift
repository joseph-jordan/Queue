//
//  Database.swift
//  queue
//
//  Created by Joseph Jordan on 12/9/18.
//  Copyright © 2018 queue. All rights reserved.
//

import UIKit
import Firebase

class Database: NSObject {
    let ref = Database.database().reference()
    
    static func loadUserData(uid: String, completion: (() -> Void)) {
        
        ref?.observeSingleEvent(of: .value, with: { (snapshot) in
            if let
        })
    }

}
