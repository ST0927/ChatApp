//
//  ChatappApp.swift
//  Chatapp
//
//  Created by Shigeyuki TAIRA on 2023/09/28.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct ChatappApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var userStore = UserStore()
    
    var body: some Scene {
      WindowGroup {
        NavigationView {
          ContentView()
                .environmentObject(userStore)
        }
      }
    }
  }

//import Foundation
//
//class UserStore : ObservableObject {
//    @Published var isAuthenticated = false
//}



