# ABNScheduler [![Build Status](https://travis-ci.org/ahmdx/ABNScheduler.svg?branch=master)](https://travis-ci.org/ahmdx/ABNScheduler)

ABNScheduler is a local notifications scheduler for iOS written in Swift.

## Features

- Easily schedule and manipulate local notifications
- Ability to schedule more than 64 local notifications
- Schedule flexible notifications (upcoming)

## Installation

Just copy `ABNScheduler.swift` to your project and you're ready to go.

## Usage
### Scheduling a Notification
```
var notification = ABNotification(alertBody: "A Notification")
let identifier = notification.schedule(fireDate: NSDate().nextHours(2))
```

`schedule(fireDate:)` returns the identifier of the notification if it was scheduled successfully. It returns `nil` if it was not scheduled or if it was already scheduled.

To preset an identifier to the notification:
```
var notification = ABNotification(alertBody: "A Notification", identifier: "identifier")
let identifier = notification.schedule(fireDate: NSDate().nextHours(2))
```

>nextHours(_:) is part of an NSDate extension.

You can also quickly schedule a notification:
```
let identifier = ABNScheduler.schedule(alertBody: "A Notification", fireDate: NSDate().nextDays(1))
```

>nextDays(_:) is part of an NSDate extension.

To schedule a notification for a specific time today or tomorrow:
```
let identifier = ABNScheduler.schedule(alertBody: "A Notification", fireDate: 1300.date)
```
This notification will be scheduled for 1:00 PM today if the current time precedes 1:00 PM, otherwise, it will be scheduled for tomorrow at 1:00 PM.

> date is a computed property and is part of an Int extension.

ABNScheduler uses a priority queue to handle more than 64 notifications. When the app can no more schedule additional notifications, they are added to the app's notifications queue. That's why you need to call `ABNScheduler.scheduleNotificationsFromQueue()` whenever some scheduled notifications are fired.

Additionally, the notifications queue is not saved to disk automatically, therefore, you will need to call `ABNScheduler.saveQueue()` whenever you need to persist the queue to disk. You do not need to load the queue when your app launches; this is handled automatically whenever the queue is to be accessed.

###Repeating a Notification

You can repeat a notification every hour, day, week, month, year using `Repeats` `.Hourly`, `.Daily`, `.Weekly`, `.Monthly`, `.Yearly` respectively.

Repeating a notification daily:

```
var notification = ABNotification(alertBody: "A Notification")
notification.repeatInterval = Repeats.Daily
let identifier = notification.schedule(fireDate: NSDate().nextHours(2))
```

### Retrieving a Notification
```
let notification = ABNScheduler.notificationWithIdentifier("identifier")
```

To retrieve the scheduled notifications by iOS, call `ABNScheduler.scheduledNotifications()`. This returns an array of ABNotification.

### Rescheduling a Notification
```
let notification = ABNScheduler.notificationWithIdentifier("identifier")
notification?.reschedule(fireDate: NSDate().nextMinutes(10))
```
> nextMinutes(_:) is part of an NSDate extension.

You can alternatively snooze a notification for minutes, hours or days using
`snoozeForMinutes(_:)`, `snoozeForHours(_:)` or `snoozeForDays(_:)` respectively.

If you feel that the notifications are not well organized, you can call `ABNScheduler.rescheduleNotifications()`. This will reorder the notifications scheduled by iOS and the notifications stored in the queue. This may be useful to call whenever the app launches.

### Canceling a Notification
```
let notification = ABNScheduler.notificationWithIdentifier("identifier")
ABNScheduler.cancel(notification!)
```

##### Alternatively
```
let notification = ABNScheduler.notificationWithIdentifier("identifier")
notification?.cancel()
```

You can cancel all scheduled notifications by calling `ABNScheduler.cancelAllNotifications()`.

## Drawbacks
Since the additional notifications are handled entirely by the app, it must be launched for the notifications to be scheduled by iOS. Just do not forget to call `ABNScheduler.scheduleNotificationsFromQueue()`.

## Notes
The scheduler is preset to allow 60 notifications to be scheduled by iOS. The remaining four slots are kept for the app-defined notifications that need not to be queued. These free slots are currently not handled by ABNScheduler; if you use ABNScheduler to utilize these slots, the notifications will be added to the queue. To change the maximum allowed, just update `maximumScheduledNotifications` in ABNScheduler.swift.

It is a good practice to call `ABNScheduler.scheduleNotificationsFromQueue()` inside `
application(_:didReceiveLocalNotification:)` in the AppDelegate class and when the app is launched. If you're going to call `ABNScheduler.rescheduleNotifications()` when the app launches, then no need to call `ABNScheduler.scheduleNotificationsFromQueue()`.

You can create an ABNotification instance using a UILocalNotificaion as an argument, however, make sure that this UILocalNotificaion has an `ABNIdentifier` key in its user info dictionary.

## Credits
ABNScheduler is written by Ahmed Mohamed. You are more than welcome to open issues and submit pull requests. Feel free to contact me through my email provided in my Github page.

## License

ABNScheduler is  released under the MIT license. For more details, see LICENSE.
