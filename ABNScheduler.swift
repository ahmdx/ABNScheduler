// The MIT License (MIT)
//
// Copyright (c) 2016 Ahmed Mohamed
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation
import UIKit

/// The maximum allowed notifications to be scheduled at a time by iOS.
///- important: Do not change this value. Changing this value to be over
/// 64 will cause some notifications to be discarded by iOS.
let MAX_ALLOWED_NOTIFICATIONS = 64

///- author: Ahmed Mohamed
class ABNScheduler {
    
    /// The maximum number of allowed UILocalNotification to be scheduled. Four slots
    /// are reserved if you would like to schedule notifications without them being queued.
    ///> Feel free to change this value.
    ///- attention: iOS by default allows a maximum of 64 notifications to be scheduled
    /// at a time.
    ///- seealso: `MAX_ALLOWED_NOTIFICATIONS`
    static let maximumScheduledNotifications = 60
    
    /// The key of the notification's identifier.
    private let identifierKey = "ABNIdentifier"
    /// The key of the notification's identifier.
    static let identifierKey = "ABNIdentifier"
    
    ///- parameters:
    ///    - alertBody: Alert body of the notification.
    ///    - fireDate: The date in which the notification will be fired at.
    ///- returns: Notification's identifier if it was successfully scheduled, nil otherwise.
    /// To get an ABNotificaiton instance of this notification, use this identifier with 
    /// `ABNScheduler.notificationWithIdentifier(_:)`.
    class func schedule(alertBody alertBody: String, fireDate: NSDate) -> String? {
        let notification = ABNotification(alertBody: alertBody)
        if let identifier = notification.schedule(fireDate: fireDate) {
            return identifier
        }
        return nil
    }
    
    ///Cancels the specified notification.
    ///- paramater: Notification to cancel.
    class func cancel(notification: ABNotification) {
        notification.cancel()
    }
    
    ///Cancels all scheduled UILocalNotification and clears the ABNQueue.
    class func cancelAllNotifications() {
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        ABNQueue.queue.clear()
        saveQueue()
        print("All notifications have been cancelled")
    }
    
    ///- returns: ABNotification of the farthest UILocalNotification (last to be fired).
    class func farthestLocalNotification() -> ABNotification? {
        if let localNotification = UIApplication.sharedApplication().scheduledLocalNotifications?.last {
            return notificationWithUILocalNotification(localNotification)
        }
        return nil
    }
    
    ///- returns: Count of scheduled UILocalNotification.
    class func scheduledCount() -> Int {
        return (UIApplication.sharedApplication().scheduledLocalNotifications?.count)!
    }
    
    ///- returns: Count of queued ABNotification.
    class func queuedCount() -> Int {
        return ABNQueue.queue.count()
    }
    
    ///- returns: Count of scheduled UILocalNotification and queued ABNotification.
    class func count() -> Int {
        return scheduledCount() + queuedCount()
    }
    
    ///Schedules the maximum possible number of ABNotification from the ABNQueue
    class func scheduleNotificationsFromQueue() {
        for _ in 0..<(min(maximumScheduledNotifications, MAX_ALLOWED_NOTIFICATIONS) - scheduledCount()) where ABNQueue.queue.count() > 0 {
            let notification = ABNQueue.queue.pop()
            notification.schedule(fireDate: notification.fireDate!)
        }
    }
    
    
    ///Creates an ABNotification from a UILocalNotification or from the ABNQueue.
    ///- parameter identifier: Identifier of the required notification.
    ///- returns: ABNotification if found, nil otherwise.
    class func notificationWithIdentifier(identifier: String) -> ABNotification? {
        let notifs = UIApplication.sharedApplication().scheduledLocalNotifications
        let queue = ABNQueue.queue.notificationsQueue()
        if notifs?.count == 0 && queue.count == 0 {
            return nil
        }
        
        for note in notifs! {
            let id = note.userInfo![ABNScheduler.identifierKey] as! String
            if id == identifier {
                return notificationWithUILocalNotification(note)
            }
        }
        
        if let note = ABNQueue.queue.notificationWithIdentifier(identifier) {
            return note
        }
        
        return nil
    }
    
    ///Instantiates an ABNotification from a UILocalNotification.
    ///- parameter localNotification: The UILocalNotification to instantiate an ABNotification from.
    ///- returns: The instantiated ABNotification from the UILocalNotification.
    class func notificationWithUILocalNotification(localNotification: UILocalNotification) -> ABNotification {
        return ABNotification.notificationWithUILocalNotification(localNotification)
    }
    
    
    ///Reschedules all notifications by copying them into a temporary array,
    ///cancelling them, and scheduling them again.
    class func rescheduleNotifications() {
        let notificationsCount = count()
        var notificationsArray = [ABNotification?](count: notificationsCount, repeatedValue: nil)
        
        let scheduledNotifications = UIApplication.sharedApplication().scheduledLocalNotifications
        var i = 0
        for note in scheduledNotifications! {
            let notif = notificationWithIdentifier(note.userInfo?[identifierKey] as! String)
            notificationsArray[i] = notif
            notif?.cancel()
            i += 1
        }
        
        let queuedNotifications = ABNQueue.queue.notificationsQueue()
        
        for note in queuedNotifications {
            notificationsArray[i] = note
            i += 1
        }
        
        cancelAllNotifications()
        
        for note in notificationsArray {
            note?.schedule(fireDate: (note?.fireDate)!)
        }
    }
    
    ///Retrieves the scheduled notifications and returns them as ABNotification array.
    ///- returns: ABNotification array of scheduled notifications if any, nil otherwise.
    class func scheduledNotifications() -> [ABNotification]? {
        if let localNotifications = UIApplication.sharedApplication().scheduledLocalNotifications {
            var notifications = [ABNotification]()
            
            for localNotification in localNotifications {
                notifications.append(ABNotification.notificationWithUILocalNotification(localNotification))
            }
            
            return notifications
        }
        
        return nil
    }
    
    ///- returns: The notifications queue.
    class func notificationsQueue() -> [ABNotification] {
        return ABNQueue.queue.notificationsQueue()
    }
    
    ///Persists the notifications queue to the disk
    ///> Call this method whenever you need to save changes done to the queue and/or before terminating the app.
    class func saveQueue() {
        ABNQueue.queue.save()
    }
    
    //MARK: Testing
    
    /// Use this method for development and testing.
    ///> Prints all scheduled and queued notifications.
    ///> You can freely modifiy it without worrying about affecting any functionality.
    class func listScheduledNotifications() {
        let notifs = UIApplication.sharedApplication().scheduledLocalNotifications
        let notificationQueue = ABNQueue.queue.notificationsQueue()
        
        if notifs?.count == 0 && notificationQueue.count == 0 {
            print("There are no scheduled notifications")
            return
        }
        
        print("SCHEDLUED")
        
        var i = 1
        for note in notifs! {
            let id = note.userInfo![identifierKey] as! String
            print("\(i) Alert body: \(note.alertBody!) - Fire date: \(note.fireDate!) - Repeats: \(ABNotification.calendarUnitToRepeats(calendarUnit: note.repeatInterval)) - Identifier: \(id)")
            i += 1
        }
        
        print("QUEUED")
        
        for note in notificationQueue {
            print("\(i) Alert body: \(note.alertBody) - Fire date: \(note.fireDate!) - Repeats: \(note.repeatInterval) - Identifier: \(note.identifier)")
            i += 1
        }
        
        print("")
    }
}

//MARK:-

///- author: Ahmed Mohamed
private class ABNQueue : NSObject {
    private var notifQueue = [ABNotification]()
    static let queue = ABNQueue()
    let ArchiveURL = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!.URLByAppendingPathComponent("notifications.abnqueue")
    
    override init() {
        super.init()
        if let notificationQueue = load() {
            notifQueue = notificationQueue
        }
    }
    
    ///- paramater notification ABNotification to push.
    private func push(notification: ABNotification) {
        notifQueue.insert(notification, atIndex: findInsertionPoint(notification))
    }
    
    /** Finds the position at which the new ABNotification is inserted in the queue.
     - parameter notification: ABNotification to insert.
     - returns: Index to insert the ABNotification at.
     - seealso: [swift-algorithm-club](https://github.com/hollance/swift-algorithm-club/tree/master/Ordered%20Array)
     */
    private func findInsertionPoint(notification: ABNotification) -> Int {
        var range = 0..<notifQueue.count
        while range.startIndex < range.endIndex {
            let midIndex = range.startIndex + (range.endIndex - range.startIndex) / 2
            if notifQueue[midIndex] == notification {
                return midIndex
            } else if notifQueue[midIndex] < notification {
                range.startIndex = midIndex + 1
            } else {
                range.endIndex = midIndex
            }
        }
        return range.startIndex
    }
    
    ///Removes and returns the head of the queue.
    ///- returns: The head of the queue.
    private func pop() -> ABNotification {
        return notifQueue.removeFirst()
    }
    
    ///- returns: The head of the queue.
    private func peek() -> ABNotification? {
        return notifQueue.last
    }
    
    ///Clears the queue.
    private func clear() {
        notifQueue.removeAll()
    }
    
    ///Called when an ABNotification is cancelled.
    ///- parameter index: Index of ABNotification to remove.
    private func removeAtIndex(index: Int) {
        notifQueue.removeAtIndex(index)
    }
    
    ///- returns: Count of ABNotification in the queue.
    private func count() -> Int {
        return notifQueue.count
    }
    
    ///- returns: The notifications queue.
    private func notificationsQueue() -> [ABNotification] {
        let queue = notifQueue
        return queue
    }
    
    ///- parameter identifier: Identifier of the notification to return.
    ///- returns: ABNotification if found, nil otherwise.
    private func notificationWithIdentifier(identifier: String) -> ABNotification? {
        for note in notifQueue {
            if note.identifier == identifier {
                return note
            }
        }
        return nil
    }
    
    // MARK: NSCoding
    
    ///Save queue on disk.
    ///- returns: The success of the saving operation.
    private func save() -> Bool {
        return NSKeyedArchiver.archiveRootObject(self.notifQueue, toFile: ArchiveURL.path!)
    }
    
    ///Load queue from disk.
    ///Called first when instantiating the ABNQueue singleton.
    ///You do not need to manually call this method and therefore do not declare it as public.
    private func load() -> [ABNotification]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(ArchiveURL.path!) as? Array<ABNotification>
    }
    
}

//MARK:-

///- author: Ahmed Mohamed
enum Repeats: String {
    case None, Hourly, Daily, Weekly, Monthly, Yearly
}

///A wrapper class around UILocalNotification.
///- author: Ahmed Mohamed
public class ABNotification : NSObject, NSCoding, Comparable {
    private var localNotification: UILocalNotification
    var alertBody: String
    var alertAction: String?
    var soundName: String?
    var repeatInterval = Repeats.None
    var userInfo: Dictionary<NSObject, AnyObject>
    private(set) var identifier: String
    private var scheduled = false
    var fireDate: NSDate? {
        return localNotification.fireDate
    }
    
    init(alertBody: String) {
        self.alertBody = alertBody
        self.localNotification = UILocalNotification()
        self.identifier = NSUUID().UUIDString
        self.userInfo = Dictionary<NSObject, AnyObject>()
        super.init()
    }
    
    init(alertBody: String, identifier: String) {
        self.alertBody = alertBody
        self.localNotification = UILocalNotification()
        self.identifier = identifier
        self.userInfo = Dictionary<NSObject, AnyObject>()
        super.init()
    }
    
    ///Used to instantiate an ABNotification when loaded from disk.
    private init(notification: UILocalNotification, alertBody: String, alertAction: String?, soundName: String?, identifier: String, repeats: Repeats, userInfo: Dictionary<NSObject, AnyObject>, scheduled: Bool) {
        self.alertBody = alertBody
        self.alertAction = alertAction
        self.soundName = soundName;
        self.localNotification = notification
        self.identifier = identifier
        self.userInfo = userInfo
        self.repeatInterval = repeats
        self.scheduled = scheduled
        super.init()
    }
    
    ///Schedules the notification.
    ///> Checks to see if there is enough room for the notification to be scheduled. Otherwise, the notification is queued.
    ///- parameter: fireDate The date in which the notification will be fired at.
    ///- returns: The identifier of the notification. Use this identifier to retrieve the notification using `ABNQueue.notificationWithIdentifier` and `ABNScheduler.notificationWithIdentifier` methods.
    func schedule(fireDate date: NSDate) -> String? {
        if self.scheduled {
            return nil
        } else {
            self.localNotification = UILocalNotification()
            self.localNotification.alertBody = self.alertBody
            self.localNotification.alertAction = self.alertAction
            self.localNotification.fireDate = date.removeSeconds()
            self.localNotification.soundName = (self.soundName == nil) ? UILocalNotificationDefaultSoundName : self.soundName;
            self.userInfo[ABNScheduler.identifierKey] = self.identifier
            self.localNotification.userInfo = self.userInfo
            
            if repeatInterval != .None {
                switch repeatInterval {
                case .Hourly: self.localNotification.repeatInterval = NSCalendarUnit.Hour
                case .Daily: self.localNotification.repeatInterval = NSCalendarUnit.Day
                case .Weekly: self.localNotification.repeatInterval = NSCalendarUnit.WeekOfYear
                case .Monthly: self.localNotification.repeatInterval = NSCalendarUnit.Month
                case .Yearly: self.localNotification.repeatInterval = NSCalendarUnit.Year
                default: break
                }
            }
            let count = ABNScheduler.scheduledCount()
            if count >= min(ABNScheduler.maximumScheduledNotifications, MAX_ALLOWED_NOTIFICATIONS) {
                if let farthestNotification = ABNScheduler.farthestLocalNotification() {
                    if farthestNotification > self {
                        farthestNotification.cancel()
                        ABNQueue.queue.push(farthestNotification)
                        self.scheduled = true
                        UIApplication.sharedApplication().scheduleLocalNotification(self.localNotification)
                    } else {
                        ABNQueue.queue.push(self)
                    }
                }
                return self.identifier
            }
            self.scheduled = true
            UIApplication.sharedApplication().scheduleLocalNotification(self.localNotification)
            return self.identifier
        }
    }
    
    ///Reschedules the notification.
    ///- parameter fireDate: The date in which the notification will be fired at.
    func reschedule(fireDate date: NSDate) {
        cancel()
        schedule(fireDate: date)
    }
    
    ///Cancels the notification if scheduled or queued.
    func cancel() {
        UIApplication.sharedApplication().cancelLocalNotification(self.localNotification)
        let queue = ABNQueue.queue.notificationsQueue()
        var i = 0
        for note in queue {
            if self.identifier == note.identifier {
                ABNQueue.queue.removeAtIndex(i)
                break
            }
            i += 1
        }
        scheduled = false
    }
    
    ///Snoozes the notification for a number of minutes.
    ///- parameter minutes: Minutes to snooze the notification for.
    func snoozeForMinutes(minutes: Int) {
        reschedule(fireDate: self.localNotification.fireDate!.nextMinutes(minutes))
    }
    
    ///Snoozes the notification for a number of hours.
    ///- parameter minutes: Hours to snooze the notification for.
    func snoozeForHours(hours: Int) {
        reschedule(fireDate: self.localNotification.fireDate!.nextMinutes(hours * 60))
    }
    
    ///Snoozes the notification for a number of days.
    ///- parameter minutes: Days to snooze the notification for.
    func snoozeForDays(days: Int) {
        reschedule(fireDate: self.localNotification.fireDate!.nextMinutes(days * 60 * 24))
    }
    
    ///- returns: The state of the notification.
    func isScheduled() -> Bool {
        return self.scheduled
    }
    
    ///Used by ABNotificationX classes to convert NSCalendarUnit enum to Repeats enum.
    ///- parameter calendarUnit: NSCalendarUnit to convert.
    ///- returns: Repeats type that is equivalent to the passed NSCalendarUnit.
    private class func calendarUnitToRepeats(calendarUnit cUnit: NSCalendarUnit) -> Repeats {
        switch cUnit {
        case NSCalendarUnit.Hour: return .Hourly
        case NSCalendarUnit.Day: return .Daily
        case NSCalendarUnit.WeekOfYear: return .Weekly
        case NSCalendarUnit.Month: return .Monthly
        case NSCalendarUnit.Year: return .Yearly
        default: return Repeats.None
        }
    }
    
    ///Instantiates an ABNotification from a UILocalNotification.
    ///- parameter localNotification: The UILocalNotification to instantiate an ABNotification from.
    ///- returns: The instantiated ABNotification from the UILocalNotification.
    private class func notificationWithUILocalNotification(localNotification: UILocalNotification) -> ABNotification {
        let alertBody = localNotification.alertBody!
        let alertAction = localNotification.alertAction
        let soundName = localNotification.soundName
        let identifier = localNotification.userInfo![ABNScheduler.identifierKey] as! String
        let repeats = self.calendarUnitToRepeats(calendarUnit: localNotification.repeatInterval)
        let userInfo = localNotification.userInfo!
        
        return ABNotification(notification: localNotification, alertBody: alertBody, alertAction: alertAction, soundName: soundName, identifier: identifier, repeats: repeats, userInfo: userInfo, scheduled: true)
    }
    
    // MARK: NSCoding
    
    @objc convenience public required init?(coder aDecoder: NSCoder) {
        guard let localNotification = aDecoder.decodeObjectForKey("ABNNotification") as? UILocalNotification, let alertBody =  aDecoder.decodeObjectForKey("ABNAlertBody") as? String, let alertAction = aDecoder.decodeObjectForKey("ABNAlertAction") as? String, let soundName = aDecoder.decodeObjectForKey("ABNSoundName") as? String, let repeats = aDecoder.decodeObjectForKey("ABNRepeats") as? String, let userInfo = aDecoder.decodeObjectForKey("ABNUserInfo") as? Dictionary<NSObject, AnyObject>, let identifier = aDecoder.decodeObjectForKey("ABNIdentifier") as? String, let scheduled = aDecoder.decodeObjectForKey("ABNScheduled") as? Bool else { return nil }
        
        self.init(notification: localNotification, alertBody: alertBody, alertAction: alertAction, soundName: soundName, identifier: identifier, repeats: Repeats(rawValue: repeats)!, userInfo: userInfo, scheduled: scheduled)
    }
    
    @objc public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(localNotification, forKey: "ABNNotification")
        aCoder.encodeObject(alertBody, forKey: "ABNAlertBody")
        aCoder.encodeObject(alertAction, forKey: "ABNAlertAction")
        aCoder.encodeObject(soundName, forKey: "ABNSoundName")
        aCoder.encodeObject(identifier, forKey: "ABNIdentifier")
        aCoder.encodeObject(repeatInterval.rawValue, forKey: "ABNRepeats")
        aCoder.encodeObject(userInfo, forKey: "ABNUserInfo")
        aCoder.encodeObject(scheduled, forKey: "ABNScheduled")
    }
    
}

public func <(lhs: ABNotification, rhs: ABNotification) -> Bool {
    return lhs.localNotification.fireDate?.compare(rhs.localNotification.fireDate!) == NSComparisonResult.OrderedAscending
}

public func ==(lhs: ABNotification, rhs: ABNotification) -> Bool {
    return lhs.identifier == rhs.identifier
}

//MARK:- Extensions

//MARK: NSDate

extension NSDate: Comparable {
    
    /**
     Add a number of minutes to a date.
     > This method can add and subtract minutes.
     
     - parameter minutes: The number of minutes to add.
     - returns: The date after the minutes addition.
     */
    
    func nextMinutes(minutes: Int) -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let components = NSDateComponents()
        components.minute = minutes
        return calendar.dateByAddingComponents(components, toDate: self, options: NSCalendarOptions(rawValue: 0))!
    }
    
    /**
     Add a number of hours to a date.
     > This method can add and subtract hours.
     
     - parameter hours: The number of hours to add.
     - returns: The date after the hours addition.
     */
    
    func nextHours(hours: Int) -> NSDate {
        return self.nextMinutes(hours * 60)
    }
    
    /**
     Add a number of days to a date.
     >This method can add and subtract days.
     
     - parameter days: The number of days to add.
     - returns: The date after the days addition.
     */
    
    func nextDays(days: Int) -> NSDate {
        return nextMinutes(days * 60 * 24)
    }
    
    func removeSeconds() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: self)
        return calendar.dateFromComponents(components)!
    }
    
    /**
     Creates a date object with the given time and offset. The offset is used to align the time with the GMT.
     
     - parameter time: The required time of the form HHMM.
     - parameter offset: The offset in minutes.
     - returns: Date with the specified time and offset.
     */
    
    static func dateWithTime(time: Int, offset: Int) -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: NSDate())
        components.minute = (time % 100) + offset % 60
        components.hour = (time / 100) + (offset / 60)
        var date = calendar.dateFromComponents(components)!
        if date < NSDate() {
            date = date.nextMinutes(60*24)
        }
        
        return date
    }
    
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == NSComparisonResult.OrderedAscending
}

public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == NSComparisonResult.OrderedSame
}

//MARK: Int

extension Int {
    var date: NSDate {
        return NSDate.dateWithTime(self, offset: 0)
    }
}
