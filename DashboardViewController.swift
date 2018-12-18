//
//  DashboardViewController.swift
//  queue
//
//  Created by Joseph Jordan on 11/8/18.
//  Copyright © 2018 queue. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let rowHeight : CGFloat = 45.0
    var upcoming = true
    var timer: Timer!
    var timer2: Timer!
    var progressCounter: Float = 0
    let duration: Float = 0.5
    var progressIncrement: Float = 0
    var activeRecs = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        callsToGoLabel.alpha = 0.0
        autoQueueDescriptionLabel.alpha = 0.0
        addGestureRecognizers()
        populateLabels()
        Data.refreshEventSorting()
        Data.refreshStatusesAndHotness()
        setUpDelegation()
        for rec in Data.allRecs {
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
            if rec.status == .Active && (hasFirstName || hasLastName) {
                activeRecs += 1
            }
        }
        stepper.maximumValue = Double(min(activeRecs, 100))
        slider.maximumValue = Float(min(activeRecs, 100))
        Data.amountQueued = min(activeRecs, 10)
        updateAmountQueuedLabel(amount: Data.amountQueued)
        jamButton.backgroundColor = UIColor.lightGray
        stepper.value = Double(Data.amountQueued)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        prepareDashboardItems()
        if Data.amountQueued > 0 {
            setUpQueueFunctionality()
        } else {
            slider.value = 0
        }
    }
    
    //=========================== HELPERS ============================
    func populateLabels() {
        fullNameLabel.text = Data.userName
        teamNameLabel.text = Data.userTeam
    }
    
    func prepareDashboardItems() {
        let callsToGo = Data.callsToGo()
        let streak = Data.streak()
        if callsToGo <= 0 {
            callsToGoLabel.text = "streak preserved for today"
        } else {
            if streak == 0 {
                callsToGoLabel.text = "\(callsToGo) calls to go to start streak"

            } else {
                callsToGoLabel.text = "\(callsToGo) calls to go to save streak"
            }
        }
        progressBar.simpleShape()
        progressIncrement = Data.bookPercentage() / duration / 10
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.showProgress), userInfo: nil, repeats: true)
        UIView.animate(withDuration: 0.3, delay: 0.6, options: .curveEaseOut, animations: {
            self.autoQueueDescriptionLabel.alpha = 1.0
            self.callsToGoLabel.alpha = 1.0
            if Data.amountQueued > 0 {
                self.jamButton.backgroundColor = Data.blue
            }
            }, completion: nil)
        let bookPercentage = Data.bookPercentage()
        if bookPercentage == 0 || bookPercentage.isNaN || bookPercentage.isInfinite {
            self.bookPercentageLabel.text = "0%"
        } else {
            DispatchQueue.global().async {
                let finalValue = Int(bookPercentage * 100)
                for i in 0...finalValue {
                    let sleepTime = UInt32(Double(self.duration) / Double(finalValue) * 1000000)
                    usleep(sleepTime)
                    DispatchQueue.main.async {
                        self.bookPercentageLabel.text = "\(i)%"
                    }
                }
            }
        }
        if streak == 0 {
            self.streakLabel.textColor = Data.red
            self.streakLabel.text = "0"
        } else {
            self.streakLabel.textColor = UIColor.darkText
            DispatchQueue.global().async {
                let finalValue = streak
                for i in 0...finalValue {
                    let sleepTime = UInt32(Double(self.duration) / Double(finalValue) * 1000000)
                    usleep(sleepTime)
                    DispatchQueue.main.async {
                        self.streakLabel.text = "🔥\(i)"
                    }
                }
            }
        }
        let callsToDemos = Data.callsToDemos()
        if callsToDemos == 0 || callsToDemos.isNaN || callsToDemos.isInfinite {
            callsToDemosLabel.text = "📞0"
        } else {
            DispatchQueue.global().async {
                let finalValue = Int(callsToDemos)
                for i in 0...finalValue {
                    let sleepTime = UInt32(Double(self.duration) / Double(finalValue) * 1000000)
                    usleep(sleepTime)
                    DispatchQueue.main.async {
                        self.callsToDemosLabel.text = "📞\(i)"
                    }
                }
            }
        }
    }
    
    @objc func showProgress() {
        if(progressCounter >= Data.bookPercentage()){timer.invalidate()}
        progressBar.progress = progressCounter
        progressCounter = progressCounter + progressIncrement
    }
    
    func updateAmountQueued(amount: Int) {
        slider.setValue(Float(amount), animated: true)
        stepper.value = Double(amount)
        amountQueuedLabel.text = String(amount)
        updateAmountQueuedLabel(amount: amount)
        Data.amountQueued = amount
        if amount == 0 {
            jamButton.backgroundColor = UIColor.lightGray
        } else {
            jamButton.backgroundColor = Data.blue
        }
    }
    
    func updateAmountQueuedLabel(amount: Int) {
        if activeRecs == 0 {
            autoQueueDescriptionLabel.text = "upload named contacts to use auto-queue"
        } else if amount == 0 {
            autoQueueDescriptionLabel.text = "auto-queue"
        } else if amount == 1 {
            autoQueueDescriptionLabel.text = "auto-queue your top rec"
        } else {
            autoQueueDescriptionLabel.text = "auto-queue your \(amount) top recs"
        }
    }
    
    func setUpQueueFunctionality() {
        DispatchQueue.global().async {
            for i in 0 ..< (Data.amountQueued + 1) {
                let sleepTime = UInt32(Double(self.duration) / Double(Data.amountQueued) * 1000000.0)
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event : Event
        if upcoming {
            if Data.upcomingEvents.count == 0 {return;}
            event = Data.upcomingEvents[indexPath.row]
        } else {
            if Data.pastEvents.count == 0 {return}
            event = Data.pastEvents[indexPath.row]
        }
        if let eventRec = event.rec {
            Data.thisRec = eventRec
            Data.homeIsDashboard = true
            performSegue(withIdentifier: "dashboardToViewContact", sender: self)
        } else {
            return
        }
    }
    
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
            event = Data.pastEvents[indexPath.row]
        }
        switch (event.summary) {
        case "Demo":
            cell.titleLabel.text = "Demo | " + event.rec!.getFullName()
            cell.subtitleLabel.text = event.date.getProperDescription() + " | " + event.date.getTime()
            cell.line.backgroundColor = Data.blue
        case "Call Back":
            cell.titleLabel.text = "Call Back " + event.rec!.getFullName()
            cell.subtitleLabel.text = event.date.getProperDescription() + " | " + event.date.getTime()
            cell.line.backgroundColor = UIColor.yellow
        default:
            cell.titleLabel.text = "Phone Jam"
            cell.subtitleLabel.text = event.date.getProperDescription() + " | " + event.date.getTime() + " | " + event.summary
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
        if Data.amountQueued == 0 {return}
        Data.refreshRatings()
        for i in 0..<Data.amountQueued {
            Data.callQueue.append(Data.allRecs[i])
        }
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
    
    @IBOutlet weak var progressBar: ProgressBarView!
    
    @IBOutlet weak var streakLabel: UILabel!
    @IBOutlet weak var callsToDemosLabel: UILabel!
    
    @IBOutlet weak var bookPercentageLabel: UILabel!
    
    @IBOutlet weak var callsToGoLabel: UILabel!
    
    @IBOutlet weak var statsView: UIView!
    
    @IBOutlet weak var autoQueueDescriptionLabel: UILabel!
    @IBOutlet weak var jamButton: UIButton!
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
