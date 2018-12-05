//
//  PhoneJamViewController.swift
//  queue
//
//  Created by Joseph Jordan on 12/2/18.
//  Copyright © 2018 queue. All rights reserved.
//

import UIKit

class PhoneJamViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        ownThePhoneCenterX.constant = -400
        goLabel.alpha = 0.0
        countdownLabel.text = "3"
        countdownLabel.alpha = 0.0
        topTrailing.constant = 1000
        bottomLeading.constant = 1000
        divider.alpha = 0.0
        view.layoutIfNeeded()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ownThePhoneCenterX.constant = 0
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
            }, completion: { (finished) in
                if finished {
                    UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseOut, animations: {
                        self.countdownLabel.alpha = 1.0
                        }, completion: { (finished) in
                            if finished {
                    DispatchQueue.global().async {
                        let durationPerItem = 1.0
                        let arr = [2, 1]
                        for i in arr {
                            let sleepTime = UInt32(durationPerItem * 1000000.0)
                            DispatchQueue.main.async {
                                self.countdownLabel.text = "\(i)"
                            }
                            usleep(sleepTime)
                        }
                        DispatchQueue.main.async {
                            UIView.animate(withDuration: 0.4, animations: {
                                self.countdownLabel.alpha = 0.0
                                self.ownThePhoneLabel.alpha = 0.0
                            }, completion: { (finished) in
                                if finished {
                                    UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
                                        self.goLabel.alpha = 1.0
                                    }, completion: { (finished) in
                                        if finished {
                                            UIView.animate(withDuration: 0.65, delay: 0.1, options: .curveEaseOut, animations: {
                                                self.goLabel.alpha = 0.0
                                            }, completion: { (finished) in
                                                if finished {
                                                    self.topTrailing.constant = 35
                                                    self.bottomLeading.constant = 35
                                                    UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseIn, animations: {
                                                        self.view.layoutIfNeeded()
                                                        self.divider.alpha = 1.0
                                                        }, completion: nil)
                                                }
                                            })
                                        }
                                    })
                                }
                            })
                        }
                    }
                    } })}
        })
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBOutlet weak var ownThePhoneCenterX: NSLayoutConstraint!
    @IBOutlet weak var topLeading: NSLayoutConstraint!
    @IBOutlet weak var topTrailing: NSLayoutConstraint!
    @IBOutlet weak var bottomTrailing: NSLayoutConstraint!
    @IBOutlet weak var bottomLeading: NSLayoutConstraint!
    @IBOutlet weak var ownThePhoneLabel: UILabel!
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var goLabel: UILabel!

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var divider: UIView!
}
