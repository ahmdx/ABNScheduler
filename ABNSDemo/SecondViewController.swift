//
//  SecondViewController.swift
//  ABNSDemo
//
//  Created by Ahmed Mohamed on 3/15/16.
//  Copyright © 2016 Ahmed Mohamed. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var scheduled: [ABNotification]?
    var queued: [ABNotification]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        scheduled = ABNScheduler.scheduledNotifications()
        queued = ABNScheduler.notificationsQueue()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController!.navigationItem.rightBarButtonItem?.enabled = false
        self.tabBarController!.navigationItem.leftBarButtonItem?.enabled = false
        
        scheduled = ABNScheduler.scheduledNotifications()
        queued = ABNScheduler.notificationsQueue()
        
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Table View
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "notificationCell")
        if indexPath.section == 0 {
            let alertBody = scheduled?[indexPath.row].alertBody
            let repeatInterval = (scheduled?[indexPath.row].repeatInterval.rawValue)
            cell.textLabel!.text = "\(alertBody!) -- Repeats: \(repeatInterval!)"
            if let date = scheduled?[indexPath.row].fireDate {
                cell.detailTextLabel!.text = String(date)
            }
        } else {
            let alertBody = queued?[indexPath.row].alertBody
            let repeatInterval = (queued?[indexPath.row].repeatInterval.rawValue)
            cell.textLabel!.text = "\(alertBody!) -- Repeats: \(repeatInterval!)"
            if let date = queued?[indexPath.row].fireDate {
                cell.detailTextLabel!.text = "Fire date: " + String(date)
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return ABNScheduler.scheduledCount()
        case 1: return ABNScheduler.queuedCount()
        default: return 0
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 54
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Scheduled: \(String(ABNScheduler.scheduledCount()))"
        case 1: return "Queued: \(String(ABNScheduler.queuedCount()))"
        default: return nil
        }
    }
    
}

