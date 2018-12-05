//
//  DashboardViewController.swift
//  queue
//
//  Created by Joseph Jordan on 11/8/18.
//  Copyright © 2018 queue. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let rowHeight : CGFloat = 50.0
    var upcoming = true

    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGestureRecognizers()
        populateLabels()
        Data.prepareTestValues()
        setUpDelegation()
        var activeRecs = 0
        for rec in Data.allRecs {
            if rec.status == .Active {
                activeRecs += 1
            }
        }
        stepper.maximumValue = Double(min(activeRecs, 100))
        slider.maximumValue = Float(min(activeRecs, 100))
        Data.amountQueued = min(activeRecs / 2, 25)
        stepper.value = Double(Data.amountQueued)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpQueueFunctionality()
    }
    
    //=========================== HELPERS ============================
    func populateLabels() {
        fullNameLabel.text = Data.userName
        teamNameLabel.text = Data.userTeam
    }
    
    func updateAmountQueued(amount: Int) {
        slider.setValue(Float(amount), animated: true)
        stepper.value = Double(amount)
        amountQueuedLabel.text = String(amount)
        Data.amountQueued = amount
    }
    
    func setUpQueueFunctionality() {
        let duration: Double = 0.5 //seconds
        DispatchQueue.global().async {
            for i in 0 ..< (Data.amountQueued + 1) {
                let sleepTime = UInt32(duration / Double(Data.amountQueued) * 1000000.0)
                usleep(sleepTime)
                DispatchQueue.main.async {
                    self.amountQueuedLabel.text = "\(i)"
                    self.slider.setValue(Float(i), animated: true)
                }
            }
        }
    }
    
    func setUpDelegation() {
        Data.refreshEventSorting()
        upcomingEventsTableView.delegate = self
        upcomingEventsTableView.dataSource = self
        upcomingEventsTableView.reloadData()
        if upcoming {
            upcomingEventsViewHeight.constant = max(rowHeight, min(rowHeight * CGFloat(Data.upcomingEvents.count), rowHeight * 4))
        } else {
            upcomingEventsViewHeight.constant = max(rowHeight, min(rowHeight * CGFloat(Data.pastEvents.count), rowHeight * 4))
        }
        view.layoutIfNeeded()
    }
    
    func addGestureRecognizers() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(dialButtonTriggered))
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(viewRecsButtonTriggered))
        
        swipeLeft.direction = .left
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        self.view.addGestureRecognizer(swipeLeft)
    }
    
    //=========================== DELEGATION ============================
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if upcoming {
            return max(Data.upcomingEvents.count, 1)
        } else {
            return max(Data.pastEvents.count, 1)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell") as! EventTableViewCell
        let event : Event
        if upcoming {
            if Data.upcomingEvents.count == 0 {
                cell.titleLabel.text = "No Events Upcoming"
                cell.subtitleLabel.text = "Book some demos! 😊"
                cell.line.backgroundColor = UIColor.gray
                return cell
            }
            event = Data.upcomingEvents[indexPath.row]
        } else {
            if Data.pastEvents.count == 0 {
                cell.titleLabel.text = "No Recent Activity"
                cell.subtitleLabel.text = ""
                cell.line.backgroundColor = UIColor.gray
                return cell
            }
            event = Data.pastEvents[Data.pastEvents.count - 1 - indexPath.row]
        }
        switch (event.summary) {
        case "Demo":
            cell.titleLabel.text = "Demo with " + event.rec!.getFullName()
            cell.subtitleLabel.text = event.date.getTime() + ", " + event.date.getProperDescription()
            cell.line.backgroundColor = Data.blue
        case "Call Back":
            cell.titleLabel.text = "Call Back " + event.rec!.getFullName()
            cell.subtitleLabel.text = event.date.getTime() + ", " + event.date.getProperDescription()
            cell.line.backgroundColor = UIColor.yellow
        default:
            cell.titleLabel.text = "Phone Jam"
            cell.subtitleLabel.text = event.date.getTime() + ", " + event.date.getProperDescription() + " | " + event.summary
            cell.line.backgroundColor = UIColor.red
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
    //=========================== OUTLETS ============================
    
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var viewRecsButton: UIButton!
    @IBOutlet weak var dialButton: UIButton!
    @IBOutlet weak var addRecButton: UIButton!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var teamNameLabel: UILabel!
    
    //constraints
    
    @IBOutlet weak var goButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var addRecButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var settingsButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var viewRecsButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var dialButtonWidth: NSLayoutConstraint!
    
    @IBAction func addRecButtonTriggered(_ sender: Any) {
    }
    @IBAction func goButtonTriggered(_ sender: Any) {
    }
    @IBAction func dialButtonTriggered(_ sender: Any) {
        if !slider.isSelected {
            performSegue(withIdentifier: "dialpad", sender: self)
        }
    }
    @IBAction func viewRecsButtonTriggered(_ sender: Any) {
        if !slider.isSelected {
            performSegue(withIdentifier: "viewRecs", sender: self)
        }
    }
    
    @IBOutlet weak var amountQueuedLabel: UILabel!
    @IBAction func stepperValueChanged(_ sender: Any) {
        updateAmountQueued(amount: (Int(stepper.value)))
    }
    @IBAction func sendButtonTriggered(_ sender: Any) {
        performSegue(withIdentifier: "dashboardToJam", sender: self)
    }
    @IBAction func sliderValueChanged(_ sender: Any) {
        updateAmountQueued(amount: Int(slider.value))
    }
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var upcomingEventsView: UIView!
    @IBOutlet weak var upcomingEventsTableView: UITableView!
    @IBOutlet weak var upcomingEventsViewHeight: NSLayoutConstraint!
    @IBAction func eventsSegmentTriggered(_ sender: Any) {
        upcoming = !upcoming
        upcomingEventsTableView.reloadData()
        if upcoming {
            upcomingEventsViewHeight.constant = max(rowHeight, min(rowHeight * CGFloat(Data.upcomingEvents.count), rowHeight * 4))
        } else {
            upcomingEventsViewHeight.constant = max(rowHeight, min(rowHeight * CGFloat(Data.pastEvents.count), rowHeight * 4))
        }
        UIView.animateKeyframes(withDuration: 0.2, delay: 0.0, animations: {self.view.layoutIfNeeded()}, completion: nil)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
