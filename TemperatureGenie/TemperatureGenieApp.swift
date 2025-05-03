//
//  TemperatureGenieApp.swift
//  TemperatureGenie
//
//  Created by Andrew Donnelly on 25/03/2025.
//

import SwiftUI
import FirebaseCore
import FirebaseMessaging

let apiPath = Bundle.main.infoDictionary!["APIPATH"] as? String ?? "https://demo-api.barcodegenie.co.uk"

enum APIError: Error {
    case errorDescription(String)
    case unknown
}


class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    let gcmMessageIDKey = "gcm.message_id"
    
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      FirebaseApp.configure()

      UNUserNotificationCenter.current().delegate = self
        
      UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                  print("Permission granted: \(granted)")
                  guard granted else { return }
                  UNUserNotificationCenter.current().getNotificationSettings { settings in
                      print("Notification settings: \(settings)")
                      guard settings.authorizationStatus == .authorized else { return }
                      DispatchQueue.main.async {
                          application.registerForRemoteNotifications()
                      }
                  }
              }

        application.registerForRemoteNotifications()
      
      Messaging.messaging().delegate = self
    return true
  }
    
    func application(_ application: UIApplication,
                      didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
         print("Device Token: \(deviceToken.map { String(format: "%02.2hhx", $0) }.joined())")

         // Pass device token to FCM
         Messaging.messaging().apnsToken = deviceToken
     }

     func application(_ application: UIApplication,
                      didFailToRegisterForRemoteNotificationsWithError error: Error) {
         print("Failed to register for remote notifications: \(error.localizedDescription)")
     }

     func application(_ application: UIApplication,
                      didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                      fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
         if let messageID = userInfo[gcmMessageIDKey] {
             print("Message ID: \(messageID)")
         }

         print(userInfo)

         completionHandler(UIBackgroundFetchResult.newData)
     }

     // MARK: - UNUserNotificationCenterDelegate

     func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 willPresent notification: UNNotification,
                                 withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
         let userInfo = notification.request.content.userInfo

         print(userInfo)

         // Change this to your preferred presentation option
         completionHandler([[.banner, .badge, .sound]])
     }

     func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 didReceive response: UNNotificationResponse,
                                 withCompletionHandler completionHandler: @escaping () -> Void) {
         let userInfo = response.notification.request.content.userInfo

         print(userInfo)

         completionHandler()
     }
}

extension AppDelegate: MessagingDelegate {

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")

        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)

        // TODO: If necessary send token to application server.
    }
}

@main
struct TemperatureGenieApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

