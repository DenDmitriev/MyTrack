//
//  AppDelegate.swift
//  MyTrack
//
//  Created by Denis Dmitriev on 30.01.2023.
//

import UIKit
import GoogleMaps
//import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        requestPermisson(center: center)
        return true
    }
    
    private func requestPermisson(center: UNUserNotificationCenter) {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            guard let self = self else {
                return
            }
            guard granted else {
                print("permisson not granted")
                return
            }
            
            let content = self.createContent()
            let trigger = self.createTrigger()
            
            self.sendNotificatin(content: content, trigger: trigger)
        }
    }
    
    private func createContent() -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Title"
        content.subtitle = "Subtitle"
        content.body = "Body"
        content.sound = .default
        //content.badge = 1
        content.userInfo = ["controller" : "someController"]
        
        return content
    }
    
    private func createTrigger() -> UNNotificationTrigger {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        return trigger
    }
    
    private func sendNotificatin(content: UNNotificationContent, trigger: UNNotificationTrigger) {
        let request = UNNotificationRequest(identifier: "timeNotification", content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.add(request) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }

    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print(#function)
    }


}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(#function)
        
        let userInfo = response.notification.request.content.userInfo
        if let nameController = userInfo["controller"] as? String {
            print(nameController)
        }
    }
}
