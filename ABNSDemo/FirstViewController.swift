//
//  FirstViewController.swift
//  ABNSDemo
//
//  Created by Ahmed Abdul Badie on 3/15/16.
//  Copyright © 2016 Ahmed Abdul Badie. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    var alertBodyField: UITextField!
    var alertActionField: UITextField!
    
    var datePicker: UIDatePicker!
    var dateValue: Date?
    var repeatingPicker: UIPickerView!
    let repeatingArray = [Repeats.None.rawValue, Repeats.Hourly.rawValue, Repeats.Daily.rawValue, Repeats.Weekly.rawValue, Repeats.Monthly.rawValue, Repeats.Yearly.rawValue]
    var repeatingValue = Repeats.None
    var dateFormatter: DateFormatter!
    
    @IBOutlet weak var fireDateButton: UIButton!
    @IBOutlet weak var repeatingButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.tabBarController!.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Schedule", style: UIBarButtonItemStyle.plain, target: self, action: #selector(FirstViewController.schedule))
        self.tabBarController!.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel All", style: UIBarButtonItemStyle.plain, target: self, action: #selector(FirstViewController.cancelAll))
        
        alertBodyField = self.view.viewWithTag(10) as! UITextField
        alertBodyField.delegate = self
        alertActionField = self.view.viewWithTag(11) as! UITextField
        alertActionField.delegate = self
        
        dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.long
        dateFormatter.timeStyle = DateFormatter.Style.short
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController!.navigationItem.rightBarButtonItem?.isEnabled = true
        self.tabBarController!.navigationItem.leftBarButtonItem?.isEnabled = true
    }
    
    @objc func schedule() {
        let alertBody = alertBodyField.text
        if (alertBody?.characters.count)! > 0 && dateValue != nil {
            let note = ABNotification(alertBody: alertBody!)
            note.alertAction = alertActionField.text
            note.repeatInterval = repeatingValue
            let _ = note.schedule(fireDate: dateValue!)
            
            self.view.endEditing(true)
            return
        }
        
        print("Notification must have alert body and fire date")
    }
    
    @objc func cancelAll() {
        ABNScheduler.cancelAllNotifications()
        self.view.endEditing(true)
    }
    
    @IBAction func setFireDate() {
        if datePicker == nil {
            datePicker = UIDatePicker(frame: CGRect(x: 0,y: UIScreen.main.bounds.size.height-250, width: UIScreen.main.bounds.size.width, height: 200))
            datePicker.addTarget(self, action: #selector(FirstViewController.didSelectDate(_:)), for: UIControlEvents.valueChanged)
            self.view.addSubview(datePicker)
        }
        
        datePicker.minimumDate = Date().nextMinutes(1)
        self.view.endEditing(true)
        datePicker.isHidden = false
        if repeatingPicker != nil {
            repeatingPicker.isHidden = true
        }
        dateValue = datePicker.date
        self.fireDateButton.setTitle(dateFormatter.string(from: dateValue!), for: UIControlState())
    }
    
    @objc func didSelectDate(_ datePicker: UIDatePicker) {
        dateValue = datePicker.date
        
        self.fireDateButton.setTitle(dateFormatter.string(from: dateValue!), for: UIControlState())
    }
    
    @IBAction func setRepeating() {
        if repeatingPicker == nil {
            repeatingPicker = UIPickerView(frame: CGRect(x: 0,y: UIScreen.main.bounds.size.height-250, width: UIScreen.main.bounds.size.width, height: 200))
            repeatingPicker.delegate = self
            self.view.addSubview(repeatingPicker)
        }
        self.view.endEditing(true)
        repeatingPicker.isHidden = false
        if datePicker != nil {
            datePicker.isHidden = true
        }
        self.repeatingButton.setTitle(repeatingArray[0], for: UIControlState())
    }
    
    //MARK: Picker View
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return repeatingArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return repeatingArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 44
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.repeatingValue = Repeats(rawValue: repeatingArray[row])!
        self.repeatingButton.setTitle(repeatingArray[row], for: UIControlState())
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

