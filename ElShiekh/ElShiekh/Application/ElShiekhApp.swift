//
//  ElShiekhApp.swift
//  ElShiekh
//
//  Created by Esraa Ehab on 01/08/2026.
//

import SwiftUI
import Authentication
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                self.setupNotificationCategories()
            }
        }
        return true
    }
    
    private func setupNotificationCategories() {
        let answerAction = UNNotificationAction(identifier: "ANSWER_ACTION", title: "Answer", options: [.foreground])
        let declineAction = UNNotificationAction(identifier: "DECLINE_ACTION", title: "Decline", options: [.destructive])
        
        let callCategory = UNNotificationCategory(
            identifier: "INCOMING_CALL",
            actions: [answerAction, declineAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([callCategory])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        switch response.actionIdentifier {
        case "ANSWER_ACTION":
            NotificationCenter.default.post(name: NSNotification.Name("AnswerCall"), object: nil, userInfo: userInfo)
        case "DECLINE_ACTION":
            NotificationCenter.default.post(name: NSNotification.Name("DeclineCall"), object: nil, userInfo: userInfo)
        case UNNotificationDefaultActionIdentifier:
            NotificationCenter.default.post(name: NSNotification.Name("AnswerCall"), object: nil, userInfo: userInfo)
        default:
            break
        }
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}

@main
struct ElShiekhApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var authManager = AuthManager.shared

    init() {
        // Wire up the network interceptor to use Keychain tokens
        // and AuthManager's refresh logic (replaces the hardcoded test token).
        AuthManager.configureInterceptor()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .task {
                    // Attempt silent login: checks Keychain for existing tokens,
                    // validates them against /auth/me, and sets authState accordingly.
                    authManager.silentLoginOnLaunch()
                }
        }
    }
}
