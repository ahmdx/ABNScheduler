//
//  FirstViewController.swift
//  ABNSDemo
//
//  Created by Ahmed Mohamed on 3/15/16.
//  Copyright © 2016 Ahmed Mohamed. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    var alertBodyField: UITextField!
    var alertActionField: UITextField!
    
    var datePicker: UIDatePicker!
    var dateValue: NSDate?
    var repeatingPicker: UIPickerView!
    let repeatingArray = [Repeats.None.rawValue, Repeats.Hourly.rawValue, Repeats.Daily.rawValue, Repeats.Weekly.rawValue, Repeats.Monthly.rawValue, Repeats.Yearly.rawValue]
    var repeatingValue = Repeats.None
    var dateFormatter: NSDateFormatter!
    
    @IBOutlet weak var fireDateButton: UIButton!
    @IBOutlet weak var repeatingButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.tabBarController!.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Schedule", style: UIBarButtonItemStyle.Plain, target: self, action: "schedule")
        self.tabBarController!.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel All", style: UIBarButtonItemStyle.Plain, target: self, action: "cancelAll")
        
        alertBodyField = self.view.viewWithTag(10) as! UITextField
        alertBodyField.delegate = self
        alertActionField = self.view.viewWithTag(11) as! UITextField
        alertActionField.delegate = self
        
        dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tabBarController!.navigationItem.rightBarButtonItem?.enabled = true
        self.tabBarController!.navigationItem.leftBarButtonItem?.enabled = true
    }
    
    func schedule() {
        let alertBody = alertBodyField.text
        if alertBody?.characters.count > 0 && dateValue != nil {
            let note = ABNotification(alertBody: alertBody!)
            note.alertAction = alertActionField.text
            note.repeatInterval = repeatingValue
            note.schedule(fireDate: dateValue!)
            
            self.view.endEditing(true)
            return
        }
        
        print("Notification must have alert body and fire date")
    }
    
    func cancelAll() {
        ABNScheduler.cancelAllNotifications()
        self.view.endEditing(true)
    }
    
    @IBAction func setFireDate() {
        if datePicker == nil {
            datePicker = UIDatePicker(frame: CGRectMake(0,UIScreen.mainScreen().bounds.size.height-250, UIScreen.mainScreen().bounds.size.width, 200))
            datePicker.addTarget(self, action: "didSelectDate:", forControlEvents: UIControlEvents.ValueChanged)
            self.view.addSubview(datePicker)
        }
        
        datePicker.minimumDate = NSDate().nextMinutes(1)
        self.view.endEditing(true)
        datePicker.hidden = false
        if repeatingPicker != nil {
            repeatingPicker.hidden = true
        }
        dateValue = datePicker.date
        self.fireDateButton.setTitle(dateFormatter.stringFromDate(dateValue!), forState: UIControlState.Normal)
    }
    
    func didSelectDate(datePicker: UIDatePicker) {
        dateValue = datePicker.date
        
        self.fireDateButton.setTitle(dateFormatter.stringFromDate(dateValue!), forState: UIControlState.Normal)
    }
    
    @IBAction func setRepeating() {
        if repeatingPicker == nil {
            repeatingPicker = UIPickerView(frame: CGRectMake(0,UIScreen.mainScreen().bounds.size.height-250, UIScreen.mainScreen().bounds.size.width, 200))
            repeatingPicker.delegate = self
            self.view.addSubview(repeatingPicker)
        }
        self.view.endEditing(true)
        repeatingPicker.hidden = false
        if datePicker != nil {
            datePicker.hidden = true
        }
        self.repeatingButton.setTitle(repeatingArray[0], forState: UIControlState.Normal)
    }
    
    //MARK: Picker View
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return repeatingArray.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return repeatingArray[row]
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 44
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.repeatingValue = Repeats(rawValue: repeatingArray[row])!
        self.repeatingButton.setTitle(repeatingArray[row], forState: UIControlState.Normal)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

