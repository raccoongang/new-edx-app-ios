//
//  FCMListener.swift
//  OpenEdX
//
//  Created by Anton Yarmolenka on 24/01/2024.
//

import Foundation

class FCMListener: PushNotificationsListener {
    // check if userinfo contains data for this Listener
    func shouldListenNotification(userinfo: [AnyHashable: Any]) -> Bool { false }
}
