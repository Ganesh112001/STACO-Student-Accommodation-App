import Foundation
import UserNotifications
import FirebaseMessaging
import UIKit

class NotificationManager: NSObject {  // Change to inherit from NSObject
    static let shared = NotificationManager()
    
    private override init() {  // Add 'override' since NSObject has init()
        super.init()  // Call superclass initializer
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    func setupMessaging() {
        Messaging.messaging().delegate = self
        
        // Register for device token
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func subscribeToInterestNotifications(userId: String) {
        Messaging.messaging().subscribe(toTopic: "interest_\(userId)")
    }
    
    func unsubscribeFromInterestNotifications(userId: String) {
        Messaging.messaging().unsubscribe(fromTopic: "interest_\(userId)")
    }
    
    func sendLocalNotification(title: String, body: String, completion: @escaping () -> Void = {}) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending notification: \(error.localizedDescription)")
            }
            
            completion()
        }
    }
}

extension NotificationManager: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let token = fcmToken {
            // You can send this token to your server for targeted push notifications
            print("Firebase registration token: \(token)")
        }
    }
}
