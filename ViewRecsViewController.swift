//
//  ViewRecsViewController.swift
//  queue
//
//  Created by Joseph Jordan on 11/24/18.
//  Copyright © 2018 queue. All rights reserved.
//

import UIKit

class ViewRecsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        Data.currentGroup = .Active
        addGestureRecognizer()
        prepareDelegation()
        prepareQueueButtons()
        prepareFilterView()
        Data.refreshFilter()
    }
    
    //=================== FILE VARIABLES ========================================
    let highlightColor = Data.lightBlue
    
    //=================== SETUP =================================================
    
    func prepareQueueButtons() {
        goButton.isHidden = true
        clearButton.isHidden = true
        goButton.alpha = 0.0
        clearButton.alpha = 0.0
    }
    
    func sortEntries() {
        for rec in Data.allRecs {
            rec.sortEntries()
        }
    }
    
    func prepareFilterView() {
        filterView.isHidden = true
        closeButton.layer.cornerRadius = 5
        switch (Data.filter) {
        case .AlphaLast:
            sortsSegmentOutlet.selectedSegmentIndex = 1
            searchBar.placeholder = "Search by Name or Phone Number"
        case .AlphaFirst:
            sortsSegmentOutlet.selectedSegmentIndex = 0
            searchBar.placeholder = "Search by Name or Phone Number"
        case .ByRef:
            sortsSegmentOutlet.selectedSegmentIndex = 2
            searchBar.placeholder = "Search by Referrer"
        }
        
        switch Data.currentGroup {
        case .Active:
            filtersSegmentOutlet.selectedSegmentIndex = 0
        case .CallBacks:
            filtersSegmentOutlet.selectedSegmentIndex = 1
        case .Declined:
            filtersSegmentOutlet.selectedSegmentIndex = 3
        default:
            filtersSegmentOutlet.selectedSegmentIndex = 2
        }
        filterViewLeadingConstraint.constant = -self.view.frame.width
    }
    
    func prepareDelegation() {
        contactsTableView.delegate = self
        contactsTableView.dataSource = self
        contactsTableView.reloadData()
        searchBar.delegate = self
    }
    
    func addGestureRecognizer() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(goToDashboard))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
    }
    
    //================== HELPERS ==============================================
    
    
    
    //================== SEARCH BAR DELEGATION ================================
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        Data.refreshFilter()
        contactsTableView.reloadData()
        searchBar.text = ""
    }
    
    /*func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.resignFirstResponder()
        return true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }*/
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            Data.refreshFilter()
            contactsTableView.reloadData()
        }
        Data.refreshFilter()
        if Data.filter == .ByRef {
            for ref in Data.sectionHeaders {
                if !ref.contains(searchText) {
                    Data.filteredRecs.remove(at: Data.sectionHeaders.index(of: ref)!)
                    Data.sectionHeaders.remove(at: Data.sectionHeaders.index(of: ref)!)
                }
            }
        } else {
            Data.filteredRecs[0] = Data.filteredRecs[0].filter({
                switch ($0.firstName, $0.lastName) {
                case (.none, .none):
                    return $0.phoneNumber.contains(searchText)
                case(.some(let first), .none):
                    return $0.phoneNumber.contains(searchText) || first.contains(searchText)
                case(.none, .some(let last)):
                    return $0.phoneNumber.contains(searchText) || last.contains(searchText)
                case(.some(let first), .some(let last)):
                    return $0.phoneNumber.contains(searchText) || first.contains(searchText) || last.contains(searchText)
                }
            })
        }
        contactsTableView.reloadData()
    }
    
    //=================== FILTERING ANIMATION FUNCTIONS========================
    func presentFilterView() {
        filterViewLeadingConstraint.constant = 0
        filterView.isHidden = false
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {self.view.layoutIfNeeded()}, completion: nil)
    }
    
    func hideFilterView() {
        filterViewLeadingConstraint.constant = -self.view.frame.width
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {self.view.layoutIfNeeded()}, completion: { finished in
            if (finished) {
                self.filterView.isHidden = true
            }
        })
    }
    
    //=================== QUEUEING ANIMATION FUNCTIONS=========================
    func presentQueueButtons() {
        goButton.isHidden = false
        clearButton.isHidden = false
        self.navigationViewBottomConstraint.constant -= 90
        UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        }, completion: { finished in
            if finished {
                self.statusLabel.text = "1 Contact Queued"
                UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseOut, animations: {
                    self.goButton.alpha = 1.0
                    self.clearButton.alpha = 1.0
                    }, completion: nil)
            }
        })
    }
    
    func hideQueueButtons() {
                UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseOut, animations: {
                    self.goButton.alpha = 0.0
                    self.clearButton.alpha = 0.0
                }, completion: { (finished) in
                    if finished {
                        self.goButton.isHidden = true
                        self.clearButton.isHidden = true
                        self.statusLabel.text = "Contacts"
                        self.navigationViewBottomConstraint.constant += 90
                        UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseOut, animations: {
                            self.view.layoutIfNeeded()
                        }, completion: nil)
                    }
                })
    }
    
    func fadeTransition(_ duration: CFTimeInterval, label: UILabel) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
            CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.fade
        animation.duration = duration
        label.layer.add(animation, forKey: CATransitionType.fade.rawValue)
    }
    
    //=================== TABLE VIEW DELEGATION FUNCTIONS=========================
    func numberOfSections(in tableView: UITableView) -> Int {
        return Data.sectionHeaders.count == 0 ? 1 : Data.sectionHeaders.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section >= Data.sectionHeaders.count ? nil : Data.sectionHeaders[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Data.filteredRecs[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = contactsTableView.dequeueReusableCell(withIdentifier: "recCell", for: indexPath) as! RecTableViewCell
        
        let currentRec = Data.filteredRecs[indexPath.section][indexPath.row]
        
        if currentRec.isQueued {
            cell.backgroundColor = highlightColor
            cell.tableViewColor = highlightColor
        } else {
            cell.backgroundColor = UIColor.white
            cell.tableViewColor = UIColor.white
        }
        cell.recNameLabel.text = currentRec.getFullName()

        cell.referrerNameLabel.text = currentRec.referrer ?? ""
        
        switch (currentRec.hot, currentRec.starred) {
        case (true, true):
            cell.primaryIconLabel.text = "🔥"
            cell.secondaryIconLabel.text = "⭐️"
        case (true, false):
            cell.primaryIconLabel.text = "🔥"
            cell.secondaryIconLabel.text = ""
        case (false, true):
            cell.primaryIconLabel.text = "⭐️"
            cell.secondaryIconLabel.text = ""
        default:
            cell.primaryIconLabel.text = ""
            cell.secondaryIconLabel.text = ""
        }
        
        if currentRec.isExpanded {
            cell.dropdownButton.setImage(UIImage(named: "flipped dropdown icon.png"), for: .normal)
        } else {
            cell.dropdownButton.setImage(UIImage(named: "dropdown icon.png"), for: .normal)
        }
        
        cell.phoneNumberLabel.text = currentRec.phoneDescription()
        cell.historyLabel.text = "History (\(currentRec.numCalls) Calls, \(currentRec.numAnswers) Answers)"
        cell.tableView.dataSource = cell
        cell.tableView.delegate = cell
        cell.entries = currentRec.getEntries()
        cell.tableViewHeight.constant = CGFloat(min(25 * currentRec.getEntries().count, 150))
        cell.tableView.reloadData()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let thisRec = Data.filteredRecs[indexPath.section][indexPath.row]
        if thisRec.isQueued {
            thisRec.isQueued = false
            Data.callQueue.remove(at: Data.callQueue.index(of: thisRec)!)
            if Data.callQueue.count == 0 {
                hideQueueButtons()
            } else {
                statusLabel.text = "\(Data.callQueue.count) Contacts Queued"
            }
        } else {
            Data.callQueue.append(thisRec)
            thisRec.isQueued = true
            if Data.callQueue.count == 1 {
                presentQueueButtons()
            } else {
                statusLabel.text = "\(Data.callQueue.count) Contacts Queued"
            }
        }
        contactsTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let rec = Data.filteredRecs[indexPath.section][indexPath.row]
        if rec.isExpanded {
            return CGFloat(88 + min(25 * rec.getEntries().count, 150))
        } else {
            return 45
        }
    }
    
    /*func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let call =
        return UISwipeActionsConfiguration(actions: [detailDisclosure, call])
    }*/
    
    // ================== HELPERS =================
    @objc func goToDashboard() {
        if Data.callQueue.count == 0 {
            performSegue(withIdentifier: "viewRecsToDashboard", sender: self)
        }
    }
    
    //=================OUTLETS==================
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var homeButtonSize: NSLayoutConstraint!
    
    @IBOutlet weak var contactsTableView: UITableView!
    
    @IBAction func filterTriggered(_ sender: Any) {
        presentFilterView()
    }
    
    @IBAction func addRecsTriggered(_ sender: Any) {
        for rec in Data.callQueue {
            rec.isQueued = false
        }
        Data.callQueue = []
        performSegue(withIdentifier: "addContact", sender: self)
    }
    
    
    @IBAction func homeButtonTriggered(_ sender: Any) {
        performSegue(withIdentifier: "viewRecsToDashboard", sender: self)
    }
    
    @IBAction func dialpadTriggered(_ sender: Any) {
        performSegue(withIdentifier: "viewRecsToDialpad", sender: self)
    }
    
    @IBAction func dropdownTriggered(_ sender: Any) {
        if let button = sender as? UIButton {
            if let cell = button.superview?.superview as? RecTableViewCell {
                 let indexPath = self.contactsTableView.indexPath(for: cell)!
                    let rec = Data.filteredRecs[indexPath.section][indexPath.row]
                    rec.isExpanded = !rec.isExpanded
                if (rec.isExpanded) {
                    cell.dropdownButton.setImage(UIImage(named: "flipped dropdown icon.png"), for: .normal)
                } else {
                    cell.dropdownButton.setImage(UIImage(named: "dropdown icon.png"), for: .normal)
                }
                self.contactsTableView.reloadRows(at: [indexPath], with: .automatic)
                
            }
        }
    }
    
    @IBAction func moreTriggered(_ sender: Any) {
        if let button = sender as? UIButton {
            if let cell = button.superview?.superview as? RecTableViewCell {
                let indexPath = self.contactsTableView.indexPath(for: cell)!
                Data.thisRec = Data.filteredRecs[indexPath.section][indexPath.row]
                for rec in Data.callQueue {
                    rec.isQueued = false
                }
                Data.callQueue = []
                Data.homeIsDashboard = false
                performSegue(withIdentifier: "viewContact", sender: self)
            }
        }
    }
    
    
    @IBAction func goButtonTriggered(_ sender: Any) {
        performSegue(withIdentifier: "contactsToJam", sender: self)
    }
    
    @IBAction func clearButtonTriggered(_ sender: Any) {
        for rec in Data.callQueue {
            rec.isQueued = false
        }
        Data.callQueue = []
        contactsTableView.reloadData()
        hideQueueButtons()
    }
    
    
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var navigationView: UIView!
     @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var goButton: UIButton!
    
    @IBOutlet weak var clearButtonLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var navigationViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var goButtonTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBAction func closeButtonTriggered(_ sender: Any) {
        hideFilterView()
    }
    
    @IBOutlet weak var filterViewLeadingConstraint: NSLayoutConstraint!
    @IBAction func filtersSegmentControl(_ sender: Any) {
        let i = filtersSegmentOutlet.selectedSegmentIndex
        switch i {
        case 0:
            Data.currentGroup = .Active
        case 1:
            Data.currentGroup = .CallBacks
        case 2:
            Data.currentGroup = .Booked
        case 3:
            Data.currentGroup = .Declined
        default:
            Data.currentGroup = .Active
        }
        Data.refreshFilter()
        contactsTableView.reloadData()
    }
    @IBAction func sortsSegmentControl(_ sender: Any) {
        let i = sortsSegmentOutlet.selectedSegmentIndex
        switch i {
        case 0:
            Data.filter = .AlphaFirst
            searchBar.placeholder = "Search by Name or Phone Number"
        case 1:
            Data.filter = .AlphaLast
            searchBar.placeholder = "Search by Name or Phone Number"
        case 2:
            Data.filter = .ByRef
            searchBar.placeholder = "Search by Referrer"
        default:
            Data.filter = .AlphaLast
            searchBar.placeholder = "Search by Name or Phone Number"
        }
        Data.refreshFilter()
        contactsTableView.reloadData()
    }
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var sortsSegmentOutlet: UISegmentedControl!
    @IBOutlet weak var filtersSegmentOutlet: UISegmentedControl!
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
