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
    
    /// Tests whether creating an ABNotification object using the simple initializer is successful.
    func testNotificationSimpleInit() {
        let note = ABNotification(alertBody: "test")
        
        XCTAssertEqual("test", note.alertBody)
        XCTAssertNotNil(note.identifier)
        XCTAssertNotNil(note.userInfo)
        XCTAssertNil(note.alertAction)
        XCTAssertNil(note.fireDate)
    }
    
    /// Tests whether creating an ABNotification object using the long initializer is successful.
    func testNotificationLongInit() {
        let note = ABNotification(alertBody: "test", identifier: "id-test")
        
        XCTAssertEqual("test", note.alertBody)
        XCTAssertEqual("id-test", note.identifier)
        XCTAssertNotNil(note.userInfo)
        XCTAssertNil(note.alertAction)
        XCTAssertNil(note.fireDate)
    }
    
    /// Tests whether scheduling a notification is successful.
    func testNotificationSchedule() {
        let note = ABNotification(alertBody: "test")
        let _ = note.schedule(fireDate: Date().nextHours(1))
        
        XCTAssertNotNil(note.userInfo[ABNScheduler.identifierKey])
        XCTAssertEqual(true, note.isScheduled())
        XCTAssertEqual(1, ABNScheduler.scheduledCount())
        XCTAssertEqual(Date().nextHours(1).removeSeconds(), ABNScheduler.notificationWithIdentifier(note.identifier)?.fireDate?.removeSeconds())
    }
    
    /// Tests whether scheduling a notification is successful using ABNScheduler schedule class method.
    func testNotificationClassSchedule() {
        let identifier = ABNScheduler.schedule(alertBody: "test", fireDate: Date().nextHours(1))
        let note = ABNScheduler.notificationWithIdentifier(identifier!)
        
        XCTAssertNotNil(note?.userInfo[ABNScheduler.identifierKey])
        XCTAssertEqual(true, note?.isScheduled())
        XCTAssertEqual(1, ABNScheduler.scheduledCount())
        XCTAssertEqual(Date().nextHours(1).removeSeconds(), ABNScheduler.notificationWithIdentifier(identifier!)?.fireDate?.removeSeconds())
    }
    
    /// Tests whether the notification queue is being filled correctly.
    func testNotificationQueue() {
        for _ in 1...99 {
            let _ = ABNScheduler.schedule(alertBody: "test", fireDate: Date().nextHours(1))
        }
        
        XCTAssertEqual(60, ABNScheduler.scheduledCount())
        XCTAssertEqual(39, ABNScheduler.queuedCount())
    }
    
    /// Tests whether cancelling a notification is successful.
    func testNotificationCancel() {
        let note = ABNotification(alertBody: "test")
        let _ = note.schedule(fireDate: Date().nextHours(1))
        note.cancel()
        
        XCTAssertEqual(false, note.isScheduled())
        XCTAssertEqual(0, ABNScheduler.scheduledCount())
    }
    
    /// Tests whether cancelling a notification from the notification queue is successful.
    func testNotificationCancelQueue() {
        for _ in 1...60 {
            let _ = ABNScheduler.schedule(alertBody: "test", fireDate: Date().nextHours(1))
        }
        
        let note = ABNotification(alertBody: "test")
        let _ = note.schedule(fireDate: Date().nextHours(2))
        
        XCTAssertEqual(1, ABNScheduler.queuedCount())

        note.cancel()
        
        XCTAssertEqual(false, note.isScheduled())
        XCTAssertEqual(0, ABNScheduler.queuedCount())
    }
    
    /// Tests whether cancelling all notifications is successful.
    func testNotificationsCancel() {
        for _ in 1...99 {
            let _ = ABNScheduler.schedule(alertBody: "test", fireDate: Date().nextHours(1))
        }
        ABNScheduler.cancelAllNotifications()
        
        XCTAssertEqual(0, ABNScheduler.count())
    }
    
    /// Tests whether `ABNScheduler.farthestLocalNotification()` works as intended.
    func testFarthestNotification() {
        for i in 1...5 {
            let _ = ABNScheduler.schedule(alertBody: "test #\(i)", fireDate: Date().nextHours(i))
        }
        
        XCTAssertEqual("test #5", ABNScheduler.farthestLocalNotification()?.alertBody)
    }
    
    /// Tests whether retrieving an ABNotifcation by identifier is successful.
    func testNotificationWithIdentifier() {
        let _ = ABNScheduler.schedule(alertBody: "test #1", fireDate: Date().nextHours(1))
        let _ = ABNScheduler.schedule(alertBody: "test #2", fireDate: Date().nextHours(2))
        let identifier = ABNScheduler.schedule(alertBody: "test #3", fireDate: Date().nextHours(3))
        let note = ABNScheduler.notificationWithIdentifier(identifier!)
        
        XCTAssertEqual("test #3", note?.alertBody)
    }
    
    /// Tests whether notifications are scheduled by iOS correctly.
    func testScheduledNotifications() {
        for i in 1...15 {
            let _ = ABNScheduler.schedule(alertBody: "test #\(i)", fireDate: Date().nextHours(i))
        }
        
        XCTAssertEqual(15, ABNScheduler.scheduledNotifications()?.count)
    }
    
    /// Tests whether `ABNScheduler` correctly schedules notifications from the notification queue.
    func testScheduleNotificationsFromQueue() {
        for _ in 1...99 {
            let _ = ABNScheduler.schedule(alertBody: "test", fireDate: Date().nextHours(1))
        }
        
        for _ in 1...4 {
            let _ = ABNScheduler.farthestLocalNotification()?.cancel()
        }
        
        XCTAssertEqual(56, ABNScheduler.scheduledCount())
        
        ABNScheduler.scheduleNotificationsFromQueue()
        
        XCTAssertEqual(60, ABNScheduler.scheduledCount())
        XCTAssertEqual(35, ABNScheduler.queuedCount())
        
    }
    
    /// Tests whether `ABNScheduler.notificationWithUILocalNotification(_:)` works as intended.
    func testNotificationWithUILocalNotification() {
        let _ = ABNScheduler.schedule(alertBody: "test", fireDate: Date().nextHours(1))
        let localNote = UIApplication.shared.scheduledLocalNotifications?.last
        let note = ABNScheduler.notificationWithUILocalNotification(localNote!)
        
        XCTAssertEqual("test", note.alertBody)
        XCTAssertEqual(true, note.isScheduled())
        XCTAssertNotNil(localNote?.userInfo![ABNScheduler.identifierKey])
        XCTAssertNotNil(note.userInfo[ABNScheduler.identifierKey])
    }
    
    
    /// Tests whether `ABNotification.scheduled` reflects the state of the notification correctly.
    func testIsScheduled() {
        let identifier = ABNScheduler.schedule(alertBody: "test", fireDate: Date().nextHours(1))
        let note = ABNScheduler.notificationWithIdentifier(identifier!)
        
        XCTAssertEqual(true, note?.isScheduled())
        
        note?.cancel()
        
        XCTAssertEqual(false, note?.isScheduled())
    }
    
    /// Tests whether rescheduling a notification is successful.
    func testNotificationReschedule() {
        let identifier = ABNScheduler.schedule(alertBody: "test", fireDate: Date().nextHours(1))
        let note = ABNScheduler.notificationWithIdentifier(identifier!)
        
        let date = note?.fireDate
        
        note?.reschedule(fireDate: date!.nextHours(1))
        
        XCTAssertEqual(date!.nextHours(1), note?.fireDate)
        XCTAssertEqual(true, note?.isScheduled())
    }
    
    /// Tests whether snoozing a notification for minitues is successful.
    func testNotificationMinutesSnooze() {
        let identifier = ABNScheduler.schedule(alertBody: "test", fireDate: Date().nextHours(1))
        let note = ABNScheduler.notificationWithIdentifier(identifier!)
        
        let date = note?.fireDate
        note?.snoozeForMinutes(12)
        
        XCTAssertEqual(date!.nextMinutes(12), note?.fireDate)
        XCTAssertEqual(true, note?.isScheduled())
    }
    
    /// Tests whether snoozing a notification for hours is successful.
    func testNotificationHoursSnooze() {
        let identifier = ABNScheduler.schedule(alertBody: "test", fireDate: Date().nextHours(1))
        let note = ABNScheduler.notificationWithIdentifier(identifier!)
        
        let date = note?.fireDate
        note?.snoozeForHours(12)
        
        XCTAssertEqual(date!.nextHours(12), note?.fireDate)
        XCTAssertEqual(true, note?.isScheduled())
    }
    
    /// Tests whether snoozing a notification for days is successful.
    func testNotificationDaysSnooze() {let identifier = ABNScheduler.schedule(alertBody: "test", fireDate: Date().nextHours(1))
        let note = ABNScheduler.notificationWithIdentifier(identifier!)
        
        let date = note?.fireDate
        note?.snoozeForDays(12)
        
        XCTAssertEqual(date!.nextDays(12), note?.fireDate)
        XCTAssertEqual(true, note?.isScheduled())
    }
    
}
