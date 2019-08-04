//
//  TestableNotificationCenter.swift
//  ShuffleTests
//
//  Created by Mac Gallagher on 7/21/19.
//  Copyright © 2019 Mac Gallagher. All rights reserved.
//

import Foundation

class TestableNotificationCenter: NotificationCenter {
    
    var postedNotificationName: NSNotification.Name?
    var postedNotificationObject: Any?
    
    override func post(name aName: NSNotification.Name, object anObject: Any?) {
        postedNotificationName = aName
        postedNotificationObject = anObject
    }
}
