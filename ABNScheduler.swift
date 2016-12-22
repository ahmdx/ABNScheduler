// The MIT License (MIT)
//
// Copyright (c) 2016 Ahmed Abdul Badie
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

///- author: Ahmed Abdul Badie
class ABNScheduler {
    
    /// The maximum number of allowed UILocalNotification to be scheduled. Four slots
    /// are reserved if you would like to schedule notifications without them being queued.
    ///> Feel free to change this value.
    ///- attention: iOS by default allows a maximum of 64 notifications to be scheduled
    /// at a time.
    ///- seealso: `MAX_ALLOWED_NOTIFICATIONS`
    static let maximumScheduledNotifications = 60
    
    /// The key of the notification's identifier.
    fileprivate let identifierKey = "ABNIdentifier"
    /// The key of the notification's identifier.
    static let identifierKey = "ABNIdentifier"
    
    ///- parameters:
    ///    - alertBody: Alert body of the notification.
    ///    - fireDate: The date in which the notification will be fired at.
    ///- returns: Notification's identifier if it was successfully scheduled, nil otherwise.
    /// To get an ABNotificaiton instance of this notification, use this identifier with 
    /// `ABNScheduler.notificationWithIdentifier(_:)`.
    class func schedule(alertBody: String, fireDate: Date) -> String? {
        let notification = ABNotification(alertBody: alertBody)
        if let identifier = notification.schedule(fireDate: fireDate) {
            return identifier
        }
        return nil
    }
    
    ///Cancels the specified notification.
    ///- paramater: Notification to cancel.
    class func cancel(_ notification: ABNotification) {
        notification.cancel()
    }
    
    ///Cancels all scheduled UILocalNotification and clears the ABNQueue.
    class func cancelAllNotifications() {
        UIApplication.shared.cancelAllLocalNotifications()
        ABNQueue.queue.clear()
        saveQueue()
        print("All notifications have been cancelled")
    }
    
    ///- returns: ABNotification of the farthest UILocalNotification (last to be fired).
    class func farthestLocalNotification() -> ABNotification? {
        if let localNotification = UIApplication.shared.scheduledLocalNotifications?.last {
            return notificationWithUILocalNotification(localNotification)
        }
        return nil
    }
    
    ///- returns: Count of scheduled UILocalNotification by iOS.
    class func scheduledCount() -> Int {
        return (UIApplication.shared.scheduledLocalNotifications?.count)!
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
            let _ = notification.schedule(fireDate: notification.fireDate!)
        }
    }
    
    
    ///Creates an ABNotification from a UILocalNotification or from the ABNQueue.
    ///- parameter identifier: Identifier of the required notification.
    ///- returns: ABNotification if found, nil otherwise.
    class func notificationWithIdentifier(_ identifier: String) -> ABNotification? {
        let notifs = UIApplication.shared.scheduledLocalNotifications
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
    class func notificationWithUILocalNotification(_ localNotification: UILocalNotification) -> ABNotification {
        return ABNotification.notificationWithUILocalNotification(localNotification)
    }
    
    
    ///Reschedules all notifications by copying them into a temporary array,
    ///cancelling them, and scheduling them again.
    class func rescheduleNotifications() {
        let notificationsCount = count()
        var notificationsArray = [ABNotification?](repeating: nil, count: notificationsCount)
        
        let scheduledNotifications = UIApplication.shared.scheduledLocalNotifications
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
            let _ = note?.schedule(fireDate: (note?.fireDate)!)
        }
    }
    
    ///Retrieves the total scheduled notifications (by iOS and in the notification queue) and returns them as ABNotification array.
    ///- returns: ABNotification array of scheduled notifications if any, nil otherwise.
    class func scheduledNotifications() -> [ABNotification]? {
        if let localNotifications = UIApplication.shared.scheduledLocalNotifications {
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
        let _ = ABNQueue.queue.save()
    }
    
    //MARK: Testing
    
    /// Use this method for development and testing.
    ///> Prints all scheduled and queued notifications.
    ///> You can freely modifiy it without worrying about affecting any functionality.
    class func listScheduledNotifications() {
        let notifs = UIApplication.shared.scheduledLocalNotifications
        let notificationQueue = ABNQueue.queue.notificationsQueue()
        
        if notifs?.count == 0 && notificationQueue.count == 0 {
            print("There are no scheduled notifications")
            return
        }
        
        print("SCHEDULED")
        
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

///- author: Ahmed Abdul Badie
private class ABNQueue : NSObject {
    fileprivate var notifQueue = [ABNotification]()
    static let queue = ABNQueue()
    let ArchiveURL = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("notifications.abnqueue")
    
    override init() {
        super.init()
        if let notificationQueue = load() {
            notifQueue = notificationQueue
        }
    }
    
    ///- paramater notification ABNotification to push.
    fileprivate func push(_ notification: ABNotification) {
        notifQueue.insert(notification, at: findInsertionPoint(notification))
    }
    
    /** Finds the position at which the new ABNotification is inserted in the queue.
     - parameter notification: ABNotification to insert.
     - returns: Index to insert the ABNotification at.
     - seealso: [swift-algorithm-club](https://github.com/hollance/swift-algorithm-club/tree/master/Ordered%20Array)
     */
    fileprivate func findInsertionPoint(_ notification: ABNotification) -> Int {
        let range = 0..<notifQueue.count
        var rangeLowerBound = range.lowerBound
        var rangeUpperBound = range.upperBound
        
        while rangeLowerBound < rangeUpperBound {
            let midIndex = rangeLowerBound + (rangeUpperBound - rangeLowerBound) / 2
            if notifQueue[midIndex] == notification {
                return midIndex
            } else if notifQueue[midIndex] < notification {
                rangeLowerBound = midIndex + 1
            } else {
                rangeUpperBound = midIndex
            }
        }
        return rangeLowerBound
    }
    
    ///Removes and returns the head of the queue.
    ///- returns: The head of the queue.
    fileprivate func pop() -> ABNotification {
        return notifQueue.removeFirst()
    }
    
    ///- returns: The head of the queue.
    fileprivate func peek() -> ABNotification? {
        return notifQueue.last
    }
    
    ///Clears the queue.
    fileprivate func clear() {
        notifQueue.removeAll()
    }
    
    ///Called when an ABNotification is cancelled.
    ///- parameter index: Index of ABNotification to remove.
    fileprivate func removeAtIndex(_ index: Int) {
        notifQueue.remove(at: index)
    }
    
    ///- returns: Count of ABNotification in the queue.
    fileprivate func count() -> Int {
        return notifQueue.count
    }
    
    ///- returns: The notifications queue.
    fileprivate func notificationsQueue() -> [ABNotification] {
        let queue = notifQueue
        return queue
    }
    
    ///- parameter identifier: Identifier of the notification to return.
    ///- returns: ABNotification if found, nil otherwise.
    fileprivate func notificationWithIdentifier(_ identifier: String) -> ABNotification? {
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
    fileprivate func save() -> Bool {
        return NSKeyedArchiver.archiveRootObject(self.notifQueue, toFile: ArchiveURL.path)
    }
    
    ///Load queue from disk.
    ///Called first when instantiating the ABNQueue singleton.
    ///You do not need to manually call this method and therefore do not declare it as public.
    fileprivate func load() -> [ABNotification]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: ArchiveURL.path) as? Array<ABNotification>
    }
    
}

//MARK:-

///- author: Ahmed Abdul Badie
enum Repeats: String {
    case None, Hourly, Daily, Weekly, Monthly, Yearly
}

///A wrapper class around UILocalNotification.
///- author: Ahmed Abdul Badie
open class ABNotification : NSObject, NSCoding, Comparable {
    fileprivate var localNotification: UILocalNotification
    var alertBody: String
    var alertAction: String?
    var soundName: String?
    var repeatInterval = Repeats.None
    var userInfo: Dictionary<String, AnyObject>
    fileprivate(set) var identifier: String
    fileprivate var scheduled = false
    var fireDate: Date? {
        return localNotification.fireDate
    }
    
    init(alertBody: String) {
        self.alertBody = alertBody
        self.localNotification = UILocalNotification()
        self.identifier = UUID().uuidString
        self.userInfo = Dictionary<String, AnyObject>()
        super.init()
    }
    
    init(alertBody: String, identifier: String) {
        self.alertBody = alertBody
        self.localNotification = UILocalNotification()
        self.identifier = identifier
        self.userInfo = Dictionary<String, AnyObject>()
        super.init()
    }
    
    ///Used to instantiate an ABNotification when loaded from disk.
    fileprivate init(notification: UILocalNotification, alertBody: String, alertAction: String?, soundName: String?, identifier: String, repeats: Repeats, userInfo: Dictionary<String, AnyObject>, scheduled: Bool) {
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
    func schedule(fireDate date: Date) -> String? {
        if self.scheduled {
            return nil
        } else {
            self.localNotification = UILocalNotification()
            self.localNotification.alertBody = self.alertBody
            self.localNotification.alertAction = self.alertAction
            self.localNotification.fireDate = date.removeSeconds()
//            let info = self.userInfo
            self.localNotification.soundName = (self.soundName == nil) ? UILocalNotificationDefaultSoundName : self.soundName;
            self.userInfo[ABNScheduler.identifierKey] = self.identifier as AnyObject?
            self.localNotification.userInfo = self.userInfo
            
            if repeatInterval != .None {
                switch repeatInterval {
                case .Hourly: self.localNotification.repeatInterval = NSCalendar.Unit.hour
                case .Daily: self.localNotification.repeatInterval = NSCalendar.Unit.day
                case .Weekly: self.localNotification.repeatInterval = NSCalendar.Unit.weekOfYear
                case .Monthly: self.localNotification.repeatInterval = NSCalendar.Unit.month
                case .Yearly: self.localNotification.repeatInterval = NSCalendar.Unit.year
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
                        UIApplication.shared.scheduleLocalNotification(self.localNotification)
                    } else {
                        ABNQueue.queue.push(self)
                    }
                }
                return self.identifier
            }
            self.scheduled = true
            UIApplication.shared.scheduleLocalNotification(self.localNotification)
            return self.identifier
        }
    }
    
    ///Reschedules the notification.
    ///- parameter fireDate: The date in which the notification will be fired at.
    func reschedule(fireDate date: Date) {
        cancel()
        let _ = schedule(fireDate: date)
    }
    
    ///Cancels the notification if scheduled or queued.
    func cancel() {
        UIApplication.shared.cancelLocalNotification(self.localNotification)
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
    func snoozeForMinutes(_ minutes: Int) {
        reschedule(fireDate: self.localNotification.fireDate!.nextMinutes(minutes))
    }
    
    ///Snoozes the notification for a number of hours.
    ///- parameter minutes: Hours to snooze the notification for.
    func snoozeForHours(_ hours: Int) {
        reschedule(fireDate: self.localNotification.fireDate!.nextHours(hours))
    }
    
    ///Snoozes the notification for a number of days.
    ///- parameter minutes: Days to snooze the notification for.
    func snoozeForDays(_ days: Int) {
        reschedule(fireDate: self.localNotification.fireDate!.nextDays(days))
    }
    
    ///- returns: The state of the notification.
    func isScheduled() -> Bool {
        return self.scheduled
    }
    
    ///Used by ABNotificationX classes to convert NSCalendarUnit enum to Repeats enum.
    ///- parameter calendarUnit: NSCalendarUnit to convert.
    ///- returns: Repeats type that is equivalent to the passed NSCalendarUnit.
    fileprivate class func calendarUnitToRepeats(calendarUnit cUnit: NSCalendar.Unit) -> Repeats {
        switch cUnit {
        case NSCalendar.Unit.hour: return .Hourly
        case NSCalendar.Unit.day: return .Daily
        case NSCalendar.Unit.weekOfYear: return .Weekly
        case NSCalendar.Unit.month: return .Monthly
        case NSCalendar.Unit.year: return .Yearly
        default: return Repeats.None
        }
    }
    
    ///Instantiates an ABNotification from a UILocalNotification.
    ///- parameter localNotification: The UILocalNotification to instantiate an ABNotification from.
    ///- returns: The instantiated ABNotification from the UILocalNotification.
    fileprivate class func notificationWithUILocalNotification(_ localNotification: UILocalNotification) -> ABNotification {
        let alertBody = localNotification.alertBody!
        let alertAction = localNotification.alertAction
        let soundName = localNotification.soundName
        let identifier = localNotification.userInfo![ABNScheduler.identifierKey] as! String
        let repeats = self.calendarUnitToRepeats(calendarUnit: localNotification.repeatInterval)
        let userInfo = localNotification.userInfo!
        
        return ABNotification(notification: localNotification, alertBody: alertBody, alertAction: alertAction, soundName: soundName, identifier: identifier, repeats: repeats, userInfo: userInfo as! Dictionary<String, AnyObject>, scheduled: true)
    }
    
    // MARK: NSCoding
    
    @objc convenience public required init?(coder aDecoder: NSCoder) {
        guard let localNotification = aDecoder.decodeObject(forKey: "ABNNotification") as? UILocalNotification, let alertBody =  aDecoder.decodeObject(forKey: "ABNAlertBody") as? String, let repeats = aDecoder.decodeObject(forKey: "ABNRepeats") as? String, let userInfo = aDecoder.decodeObject(forKey: "ABNUserInfo") as? Dictionary<String, AnyObject>, let identifier = aDecoder.decodeObject(forKey: "ABNIdentifier") as? String, let scheduled = aDecoder.decodeObject(forKey: "ABNScheduled") as? Bool else { return nil }
        
        let alertAction = aDecoder.decodeObject(forKey: "ABNAlertAction") as? String
        let soundName = aDecoder.decodeObject(forKey: "ABNSoundName") as? String
        
        self.init(notification: localNotification, alertBody: alertBody, alertAction: alertAction, soundName: soundName, identifier: identifier, repeats: Repeats(rawValue: repeats)!, userInfo: userInfo, scheduled: scheduled)
    }
    
    @objc open func encode(with aCoder: NSCoder) {
        aCoder.encode(localNotification, forKey: "ABNNotification")
        aCoder.encode(alertBody, forKey: "ABNAlertBody")
        aCoder.encode(alertAction, forKey: "ABNAlertAction")
        aCoder.encode(soundName, forKey: "ABNSoundName")
        aCoder.encode(identifier, forKey: "ABNIdentifier")
        aCoder.encode(repeatInterval.rawValue, forKey: "ABNRepeats")
        aCoder.encode(userInfo, forKey: "ABNUserInfo")
        aCoder.encode(scheduled, forKey: "ABNScheduled")
    }
    
}

public func <(lhs: ABNotification, rhs: ABNotification) -> Bool {
    return lhs.localNotification.fireDate?.compare(rhs.localNotification.fireDate!) == ComparisonResult.orderedAscending
}

public func ==(lhs: ABNotification, rhs: ABNotification) -> Bool {
    return lhs.identifier == rhs.identifier
}

//MARK:- Extensions

//MARK: NSDate

extension Date {
    
    /**
     Add a number of minutes to a date.
     > This method can add and subtract minutes.
     
     - parameter minutes: The number of minutes to add.
     - returns: The date after the minutes addition.
     */
    
    func nextMinutes(_ minutes: Int) -> Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.minute = minutes
        return (calendar as NSCalendar).date(byAdding: components, to: self, options: NSCalendar.Options(rawValue: 0))!
    }
    
    /**
     Add a number of hours to a date.
     > This method can add and subtract hours.
     
     - parameter hours: The number of hours to add.
     - returns: The date after the hours addition.
     */
    
    func nextHours(_ hours: Int) -> Date {
        return self.nextMinutes(hours * 60)
    }
    
    /**
     Add a number of days to a date.
     >This method can add and subtract days.
     
     - parameter days: The number of days to add.
     - returns: The date after the days addition.
     */
    
    func nextDays(_ days: Int) -> Date {
        return nextMinutes(days * 60 * 24)
    }
    
    func removeSeconds() -> Date {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.year, .month, .day, .hour, .minute], from: self)
        return calendar.date(from: components)!
    }
    
    /**
     Creates a date object with the given time and offset. The offset is used to align the time with the GMT.
     
     - parameter time: The required time of the form HHMM.
     - parameter offset: The offset in minutes.
     - returns: Date with the specified time and offset.
     */
    
    static func dateWithTime(_ time: Int, offset: Int) -> Date {
        let calendar = Calendar.current
        var components = (calendar as NSCalendar).components([.year, .month, .day, .hour, .minute], from: Date())
        components.minute = (time % 100) + offset % 60
        components.hour = (time / 100) + (offset / 60)
        var date = calendar.date(from: components)!
        if date < Date() {
            date = date.nextMinutes(60*24)
        }
        
        return date
    }
    
}

//public func <(lhs: Date, rhs: Date) -> Bool {
//    return lhs.compare(rhs) == ComparisonResult.orderedAscending
//}

//public func ==(lhs: Date, rhs: Date) -> Bool {
//    return lhs.compare(rhs) == ComparisonResult.orderedSame
//}

//MARK: Int

extension Int {
    var date: Date {
        return Date.dateWithTime(self, offset: 0)
    }
}
