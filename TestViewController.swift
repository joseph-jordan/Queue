//
//  TestViewController.swift
//  queue
//
//  Created by Joseph Jordan on 11/27/18.
//  Copyright © 2018 queue. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    var calendarSelected = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpButtons()
        Data.homeButtonWidth = 100 / 320 * self.view.frame.width
        //addGestureRecognizers()
    }
    
    //=========================== HELPERS ============================
    func addGestureRecognizers() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(dialButtonTriggered))
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(viewRecsButtonTriggered))
        
        swipeLeft.direction = .left
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        self.view.addGestureRecognizer(swipeLeft)
    }
    func setUpButtons() {
        let goButtonSize = 65 / 320 * self.view.frame.width
        let otherButtonSize = 45 / 320 * self.view.frame.width
        //let imageSize:CGSize = CGSize(width: 23, height: 20)
        goButton.setImage(UIImage(named: "White Telephone w: Circle Transparent Background.png"), for: UIControl.State.normal)
        let phoneInset = -9 + -9 / 320 * self.view.frame.width
        goButton.imageEdgeInsets = UIEdgeInsets(
            top: phoneInset,
            left: phoneInset,
            bottom: phoneInset,
            right: phoneInset)
        let gearInset = 13 / 320 * self.view.frame.width
        settingsButton.setImage(UIImage(named: "settings gear transparent.png"), for: UIControl.State.normal)
        settingsButton.imageEdgeInsets = UIEdgeInsets(
            top: gearInset,
            left: gearInset,
            bottom: gearInset,
            right: gearInset)
        let addRecButtonInset = 15 / 320 * self.view.frame.width
        addRecButton.setImage(UIImage(named: "plus sign transparent.png"), for: UIControl.State.normal)
        addRecButton.imageEdgeInsets = UIEdgeInsets(top: addRecButtonInset, left: addRecButtonInset, bottom: addRecButtonInset, right: addRecButtonInset)
        let viewRecsButtonInset = 15 / 320 * self.view.frame.width
        viewRecsButton.setImage(UIImage(named: "contacts transparent.png"), for: UIControl.State.normal)
        viewRecsButton.imageEdgeInsets = UIEdgeInsets(top: viewRecsButtonInset, left: viewRecsButtonInset, bottom: viewRecsButtonInset, right: viewRecsButtonInset)
        let dialButtonInset = 15 / 320 * self.view.frame.width
        dialButton.setImage(UIImage(named: "dialpad transparent.png"), for: UIControl.State.normal)
        dialButton.imageEdgeInsets = UIEdgeInsets(top: dialButtonInset, left: dialButtonInset, bottom: dialButtonInset, right: dialButtonInset)
        goButtonHeight.constant = goButtonSize
        addRecButtonWidth.constant = otherButtonSize
        settingsButtonHeight.constant = otherButtonSize
        viewRecsButtonHeight.constant = otherButtonSize
        dialButtonWidth.constant = otherButtonSize
        
        
        
        goButton.layer.cornerRadius = goButtonSize / 2
        goButton.clipsToBounds = true
        addRecButton.layer.cornerRadius = otherButtonSize / 2
        addRecButton.clipsToBounds = true
        settingsButton.layer.cornerRadius = otherButtonSize / 2
        settingsButton.clipsToBounds = true
        viewRecsButton.layer.cornerRadius = otherButtonSize / 2
        viewRecsButton.clipsToBounds = true
        dialButton.layer.cornerRadius = otherButtonSize / 2
        dialButton.clipsToBounds = true
    }
    
    //=========================== OUTLETS ============================
    
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var viewRecsButton: UIButton!
    @IBOutlet weak var dialButton: UIButton!
    @IBOutlet weak var addRecButton: UIButton!
    @IBOutlet weak var displayImageView: UIImageView!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var displayView: UIView!
    @IBOutlet weak var displayControl: UISegmentedControl!
    
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
        performSegue(withIdentifier: "dialpad", sender: self)
    }
    @IBAction func viewRecsButtonTriggered(_ sender: Any) {
        performSegue(withIdentifier: "viewRecs", sender: self)
    }
    
    
    @IBAction func displayControlChanged(_ sender: Any) {
        calendarSelected = !calendarSelected
        if calendarSelected {
            displayImageView.image = UIImage(named: "calendar screenshot.png")
        } else {
            displayImageView.image = UIImage(named: "Appointment_set.png")
        }
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
