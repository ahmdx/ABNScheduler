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
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController!.navigationItem.rightBarButtonItem?.isEnabled = false
        self.tabBarController!.navigationItem.leftBarButtonItem?.isEnabled = false
        
        scheduled = ABNScheduler.scheduledNotifications()
        queued = ABNScheduler.notificationsQueue()
        
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Table View
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "notificationCell")
        if indexPath.section == 0 {
            let alertBody = scheduled?[indexPath.row].alertBody
            let repeatInterval = (scheduled?[indexPath.row].repeatInterval.rawValue)
            cell.textLabel!.text = "\(alertBody!) -- Repeats: \(repeatInterval!)"
            if let date = scheduled?[indexPath.row].fireDate {
                cell.detailTextLabel!.text = String(describing: date)
            }
        } else {
            let alertBody = queued?[indexPath.row].alertBody
            let repeatInterval = (queued?[indexPath.row].repeatInterval.rawValue)
            cell.textLabel!.text = "\(alertBody!) -- Repeats: \(repeatInterval!)"
            if let date = queued?[indexPath.row].fireDate {
                cell.detailTextLabel!.text = "Fire date: " + String(describing: date)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return ABNScheduler.scheduledCount()
        case 1: return ABNScheduler.queuedCount()
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Scheduled: \(String(ABNScheduler.scheduledCount()))"
        case 1: return "Queued: \(String(ABNScheduler.queuedCount()))"
        default: return nil
        }
    }
    
}

