//
//  ABNSchedulerTests.swift
//  ABNotificationDemo
//
//  Created by Ahmed Mohamed on 3/5/16.
//  Copyright © 2016 Ahmed Mohamed. All rights reserved.
//

import XCTest
@testable import ABNSDemo

class ABNSchedulerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        ABNScheduler.cancelAllNotifications()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testNotificationSimpleInit() {
        let note = ABNotification(alertBody: "test")
        
        XCTAssertEqual("test", note.alertBody)
        XCTAssertNotNil(note.identifier)
        XCTAssertNotNil(note.userInfo)
        XCTAssertNil(note.alertAction)
        XCTAssertNil(note.fireDate)
    }
    
    func testNotificationLongInit() {
        let note = ABNotification(alertBody: "test", identifier: "id-test")
        
        XCTAssertEqual("test", note.alertBody)
        XCTAssertEqual("id-test", note.identifier)
        XCTAssertNotNil(note.userInfo)
        XCTAssertNil(note.alertAction)
        XCTAssertNil(note.fireDate)
    }
    
    func testNotificationSchedule() {
        let note = ABNotification(alertBody: "test")
        note.schedule(fireDate: NSDate().nextHours(1))
        
        XCTAssertNotNil(note.userInfo[ABNScheduler.identifierKey])
        XCTAssertEqual(true, note.isScheduled())
        XCTAssertEqual(1, ABNScheduler.scheduledCount())
    }
    
    func testNotificationClassSchedule() {
        let identifier = ABNScheduler.schedule(alertBody: "test", fireDate: NSDate().nextHours(1))
        let note = ABNScheduler.notificationWithIdentifier(identifier!)
        
        XCTAssertNotNil(note?.userInfo[ABNScheduler.identifierKey])
        XCTAssertEqual(true, note?.isScheduled())
        XCTAssertEqual(1, ABNScheduler.scheduledCount())
    }
    
    func testNotificationQueue() {
        for _ in 1...99 {
            ABNScheduler.schedule(alertBody: "test", fireDate: NSDate().nextHours(1))
        }
        
        XCTAssertEqual(60, ABNScheduler.scheduledCount())
        XCTAssertEqual(39, ABNScheduler.queuedCount())
    }
    
    func testNotificationCancel() {
        let note = ABNotification(alertBody: "test")
        note.schedule(fireDate: NSDate().nextHours(1))
        note.cancel()
        
        XCTAssertEqual(false, note.isScheduled())
        XCTAssertEqual(0, ABNScheduler.scheduledCount())
    }
    
    func testNotificationsCancel() {
        for _ in 1...99 {
            ABNScheduler.schedule(alertBody: "test", fireDate: NSDate().nextHours(1))
        }
        ABNScheduler.cancelAllNotifications()
        
        XCTAssertEqual(0, ABNScheduler.count())
    }
    
    func testFarthestNotification() {
        for i in 1...5 {
            ABNScheduler.schedule(alertBody: "test #\(i)", fireDate: NSDate().nextHours(i))
        }
        
        XCTAssertEqual("test #5", ABNScheduler.farthestLocalNotification()?.alertBody)
    }
    
    func testNotificationWithIdentifier() {
        ABNScheduler.schedule(alertBody: "test #1", fireDate: NSDate().nextHours(1))
        ABNScheduler.schedule(alertBody: "test #2", fireDate: NSDate().nextHours(2))
        let identifier = ABNScheduler.schedule(alertBody: "test #3", fireDate: NSDate().nextHours(3))
        let note = ABNScheduler.notificationWithIdentifier(identifier!)
        
        XCTAssertEqual("test #3", note?.alertBody)
    }
    
    func testScheduledNotifications() {
        for i in 1...15 {
            ABNScheduler.schedule(alertBody: "test #\(i)", fireDate: NSDate().nextHours(i))
        }
        
        XCTAssertEqual(15, ABNScheduler.scheduledNotifications()?.count)
    }
    
    func testScheduleNotificationsFromQueue() {
        for _ in 1...99 {
            ABNScheduler.schedule(alertBody: "test", fireDate: NSDate().nextHours(1))
        }
        
        for _ in 1...4 {
            ABNScheduler.farthestLocalNotification()?.cancel()
        }
        
        XCTAssertEqual(56, ABNScheduler.scheduledCount())
        
        ABNScheduler.scheduleNotificationsFromQueue()
        
        XCTAssertEqual(60, ABNScheduler.scheduledCount())
        XCTAssertEqual(35, ABNScheduler.queuedCount())
        
    }
    
    func testNotificationWithUILocalNotification() {
        ABNScheduler.schedule(alertBody: "test", fireDate: NSDate().nextHours(1))
        let localNote = UIApplication.sharedApplication().scheduledLocalNotifications?.last
        let note = ABNScheduler.notificationWithUILocalNotification(localNote!)
        
        XCTAssertEqual("test", note.alertBody)
        XCTAssertEqual(true, note.isScheduled())
        XCTAssertNotNil(localNote?.userInfo![ABNScheduler.identifierKey])
        XCTAssertNotNil(note.userInfo[ABNScheduler.identifierKey])
    }
    
    func testIsScheduled() {
        let identifier = ABNScheduler.schedule(alertBody: "test", fireDate: NSDate().nextHours(1))
        let note = ABNScheduler.notificationWithIdentifier(identifier!)
        
        XCTAssertEqual(true, note?.isScheduled())
        
        note?.cancel()
        
        XCTAssertEqual(false, note?.isScheduled())
    }
    
    func testNotificationReschedule() {
        let identifier = ABNScheduler.schedule(alertBody: "test", fireDate: NSDate().nextHours(1))
        let note = ABNScheduler.notificationWithIdentifier(identifier!)
        
        let date = note?.fireDate
        note?.reschedule(fireDate: date!.nextHours(1))
        
        XCTAssertEqual(date!.nextHours(1), note?.fireDate)
        XCTAssertEqual(true, note?.isScheduled())
    }
    
    func testNotificationMinutesSnooze() {
        let identifier = ABNScheduler.schedule(alertBody: "test", fireDate: NSDate().nextHours(1))
        let note = ABNScheduler.notificationWithIdentifier(identifier!)
        
        let date = note?.fireDate
        note?.snoozeForMinutes(12)
        
        XCTAssertEqual(date!.nextMinutes(12), note?.fireDate)
        XCTAssertEqual(true, note?.isScheduled())
    }
    
    func testNotificationHoursSnooze() {
        let identifier = ABNScheduler.schedule(alertBody: "test", fireDate: NSDate().nextHours(1))
        let note = ABNScheduler.notificationWithIdentifier(identifier!)
        
        let date = note?.fireDate
        note?.snoozeForHours(12)
        
        XCTAssertEqual(date!.nextHours(12), note?.fireDate)
        XCTAssertEqual(true, note?.isScheduled())
    }
    
    func testNotificationDaysSnooze() {let identifier = ABNScheduler.schedule(alertBody: "test", fireDate: NSDate().nextHours(1))
        let note = ABNScheduler.notificationWithIdentifier(identifier!)
        
        let date = note?.fireDate
        note?.snoozeForDays(12)
        
        XCTAssertEqual(date!.nextDays(12), note?.fireDate)
        XCTAssertEqual(true, note?.isScheduled())
    }
    
}
