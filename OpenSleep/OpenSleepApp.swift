//
//  OpenSleepApp.swift
//  OpenSleep
//
//  Created by 大澤清乃 on 2024/09/21.
//

import SwiftUI
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        print(url)
        print(url.scheme)
        print(url.host)
        print(url.path)
        print(url.query)
        
        return true
    }
}

@main
struct OpenSleepApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @State private var showFormView = false
    @State private var teacherName: String?
    @State private var classTime: String?
    
    var body: some Scene {
        WindowGroup {
            ContentView(showFormView: $showFormView, teacherName: $teacherName, classTime: $classTime)
                .onOpenURL { url in
                    handleIncomingURL(url)
                }
        }
    }
    
    private func handleIncomingURL(_ url: URL) {
        // URLからクエリアイテムを取得
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let items = components.queryItems {
            // teacherNameとclassTimeの値を取得
            teacherName = items.first(where: { $0.name == "teacherName" })?.value
            classTime = items.first(where: { $0.name == "classTime" })?.value
            showFormView = true // クエリアイテムがあればモーダルを表示
            print("🎃\(url)")
            print("🐷\(teacherName)")
            print("🐸\(classTime)")
        }
    }
}
