import Foundation

class TestableNotificationCenter: NotificationCenter {
    
    var postedNotificationName: NSNotification.Name?
    var postedNotificationObject: Any?
    
    override func post(name aName: NSNotification.Name, object anObject: Any?) {
        postedNotificationName = aName
        postedNotificationObject = anObject
    }
}
