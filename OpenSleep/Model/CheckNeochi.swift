////
////  CheckNeochi.swift
////  OpenSleep
////
////  Created by 大澤清乃 on 2024/09/21.
////
//
import Foundation
import HealthKit
import UserNotifications // 通知のために必要
import AVFoundation

class CheckNeochi: ObservableObject {
    
    @Published var latestSleepStatus: String = "No data yet"
    var useDemoData: Bool = false // デモデータ使用フラグ
    var observerQuery: HKObserverQuery?
    
    var checkNeru: Bool = false
    
    var classNum = Int()
    var startHour = Int()
    var startMin = Int()
    var endHour = Int()
    var endMin = Int()
    
    let healthStore = HKHealthStore()
    let synthesizer = AVSpeechSynthesizer()
    
    func checkPermistion() {
        
        let readTypes = Set([
            HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!
        ])
        let writeTypes = Set([
            HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!
        ])
        
        healthStore.requestAuthorization(
            toShare: writeTypes, read: readTypes,
            completion: { success, error in
                if success == false {
                    print("データにアクセスできません")
                    return
                }
                else {
                    print("できた！")
                    
                }
                
            })
    }
    
    func startObservingSleepData(schoolID: String, name: String) {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            print("Sleep Analysis Type is not available in HealthKit")
            return
        }
        
        if useDemoData {
            // デモデータを使う場合
            loadDemoData(schoolID: schoolID, name: name)
            return
        }
        
        // ObserverQueryの作成
        observerQuery = HKObserverQuery(sampleType: sleepType, predicate: nil) { [weak self] query, completionHandler, error in
            if let error = error {
                print("Observer Query Error: \(error.localizedDescription)")
                completionHandler()
                return
            }
            
            // Sleep data の更新を検知したら、データを取得
            self?.fetchLatestSleepData(schoolID: schoolID, name: name)
            
            // Observer Queryの処理が完了したことを通知
            completionHandler()
        }
        
        // ObserverQuery を HealthStore に登録
        if let observerQuery = observerQuery {
            healthStore.execute(observerQuery)
        }
        
        // バックグラウンドでの更新を有効化
        healthStore.enableBackgroundDelivery(for: sleepType, frequency: .immediate) { success, error in
            if let error = error {
                print("Error enabling background delivery: \(error.localizedDescription)")
            }
            print("Background delivery enabled: \(success)")
        }
    }
    
    // 最新の睡眠データを取得する
    func fetchLatestSleepData(schoolID: String, name: String) {
        if useDemoData {
            // デモデータモードの場合、リアルデータは取得しない
            loadDemoData(schoolID: schoolID, name: name)
            return
        }
        
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.date(byAdding: .hour, value: -1, to: Date())!, end: Date(), options: [])
        
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { query, results, error in
            if let error = error {
                print("Error fetching sleep data: \(error.localizedDescription)")
                return
            }
            
            guard let samples = results as? [HKCategorySample] else {
                print("No sleep data samples available")
                return
            }
            
            for sample in samples.reversed() {
                if sample.value == HKCategoryValueSleepAnalysis.asleep.rawValue {
                    print("ユーザーが睡眠中です。処理を実行します。")
                    self.handleSleepDetected(sample: sample, schoolID: schoolID, name: name)
                    break
                } else if sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue {
                    print("ユーザーはベッドにいますが、睡眠状態ではありません。")
                } else {
                    print("ユーザーは睡眠中ではありません。")
                    self.handleAwakeDetected(sample: sample)
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    // デモデータを使用して睡眠状態をシミュレート
    func loadDemoData(schoolID: String, name: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // 2秒後にデモデータを表示
            self.latestSleepStatus = "Asleep (Demo)"
            print("デモデータを使用してユーザーが睡眠中であることをシミュレートしています。")
            
            // デモデータが睡眠中の状態であることを確認
            self.handleSleepDetected(sample: self.createDemoSample(), schoolID: schoolID, name: name)
        }
    }
    
    // デモ用のサンプルデータを生成する
    private func createDemoSample() -> HKCategorySample {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            fatalError("Sleep Analysis Type is not available in HealthKit")
        }
        
        let startDate = Calendar.current.date(byAdding: .hour, value: -1, to: Date())!
        let endDate = Date()
        
        let demoSample = HKCategorySample(type: sleepType, value: HKCategoryValueSleepAnalysis.asleep.rawValue, start: startDate, end: endDate, metadata: nil)
        
        return demoSample
    }
    
    func speech(schoolID: String, name: String) {
        let text = AVSpeechUtterance(string: "\(schoolID)のわたくし、\(name)は、授業中にもかかわらず、寝てしまいました。")
        let language = AVSpeechSynthesisVoice(language: "ja-JP")
        text.voice = language
        synthesizer.speak(text)
    }
    
    // 睡眠データを検出したときに実行される処理
    func handleSleepDetected(sample: HKCategorySample, schoolID: String, name: String) {
        print("睡眠データを検出しました。睡眠開始時間: \(sample.startDate), 終了時間: \(sample.endDate)")
        
        self.speech(schoolID: schoolID, name: name)
        // API へのデータ送信
        API().sendDataToAPI(schoolID: schoolID, name: name) { success in
            if success {
                print("APIデータ送信に成功しました")
            } else {
                print("APIデータ送信に成功しました") //ここ！
            }
        }
        
        // ローカル通知を表示する
        DispatchQueue.main.async {
            let notificationContent = UNMutableNotificationContent()
            notificationContent.title = "睡眠状態を検出"
            notificationContent.body = "あなたは現在睡眠中です（デモ）。時間: \(sample.startDate) - \(sample.endDate)"
            notificationContent.sound = UNNotificationSound.default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("通知の表示中にエラーが発生しました: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // 睡眠していないデータを検出したときに実行される処理
    func handleAwakeDetected(sample: HKCategorySample) {
        print("ユーザーが起きています。")
    }
    
    // クエリの停止
    func stopObservingSleepData() {
        if let query = observerQuery {
            healthStore.stop(query)
            print("Observing sleep data stopped")
        }
    }
}

//import Foundation
//import HealthKit
//import HealthKitUI
//
//class CheckNeochi: ObservableObject {
//
//    @Published var latestSleepStatus: String = "No data yet"
//    var useDemoData: Bool = false // デモデータ使用フラグ
//    var observerQuery: HKObserverQuery?
//
//    var checkNeru: Bool = false
//
//    var classNum = Int()
//    var startHour = Int()
//    var startMin = Int()
//    var endHour = Int()
//    var endMin = Int()
//
//    let healthStore = HKHealthStore()
//
//    func timeSetting(classNum: Int) {
//        startHour = TimeModel().startHour[classNum - 1]
//        startMin = TimeModel().startMin[classNum - 1]
//        endHour = TimeModel().endHour[classNum - 1]
//        endMin = TimeModel().endMin[classNum - 1]
//    }
//
//    func checkPermistion() {
//
//        let readTypes = Set([
//            HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!
//        ])
//        let writeTypes = Set([
//            HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!
//        ])
//
//        healthStore.requestAuthorization(
//            toShare: writeTypes, read: readTypes,
//            completion: { success, error in
//                if success == false {
//                    print("データにアクセスできません")
//                    return
//                }
//                else {
//                    print("できた！")
//
//                }
//
//            })
//    }
//
//    func startObservingSleepData(schoolID: String, name: String) {
//        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
//            print("Sleep Analysis Type is not available in HealthKit")
//            return
//        }
//
//        // ObserverQueryの作成
//        let observerQuery = HKObserverQuery(sampleType: sleepType, predicate: nil) { [weak self] query, completionHandler, error in
//            if let error = error {
//                print("Observer Query Error: \(error.localizedDescription)")
//                completionHandler()
//                return
//            }
//
//            // Sleep data の更新を検知したら、データを取得
//            self?.fetchLatestSleepData(schoolID: schoolID, name: name)
//            print("🤮")
//
//            // Observer Queryの処理が完了したことを通知
//            completionHandler()
//        }
//
//        // ObserverQuery を HealthStore に登録
//        healthStore.execute(observerQuery)
//
//        // バックグラウンドでの更新を有効化
//        healthStore.enableBackgroundDelivery(for: sleepType, frequency: .immediate) { success, error in
//            if let error = error {
//                print("Error enabling background delivery: \(error.localizedDescription)")
//            }
//            print("Background delivery enabled: \(success)")
//        }
//    }
//
//    // 最新の睡眠データを取得する
//    func fetchLatestSleepData(schoolID: String, name: String) {
//        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
//            return
//        }
//
//        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.date(byAdding: .hour, value: -1, to: Date())!, end: Date(), options: [])
//
//        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { query, results, error in
//            if let error = error {
//                print("Error fetching sleep data: \(error.localizedDescription)")
//                return
//            }
//
//            guard let samples = results as? [HKCategorySample] else {
//                print("No sleep data samples available")
//                return
//            }
//
//            // データを逆順にして最新のデータを優先的に確認
//            for sample in samples.reversed() {
//                if sample.value == HKCategoryValueSleepAnalysis.asleep.rawValue {
//                    print("ユーザーが睡眠中です。処理を実行します。")
//                    // ここにユーザーが睡眠中の場合の処理を追加
//                    API().sendDataToAPI(schoolID: schoolID, name: name)
//                    print("おーい、寝てるよーーー")
//                    self.handleSleepDetected(sample: sample)
//                    break // 睡眠データを1つ確認したらループを終了
//                } else if sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue {
//                    print("ユーザーはベッドにいますが、睡眠状態ではありません。")
//                    // 必要に応じてinBedの処理を追加
//                } else {
//                    print("ユーザーは睡眠中ではありません。")
//                    // 睡眠していないときの処理
//                    API().sendDataToAPI(schoolID: schoolID, name: name)
//                    self.handleAwakeDetected(sample: sample)
//                }
//            }
//        }
//
//        healthStore.execute(query)
//    }
//
//    // 睡眠データを検出したときに実行される処理
//    func handleSleepDetected(sample: HKCategorySample) {
//        // ここに睡眠中の処理を記述します
//        print("睡眠データを検出しました。睡眠開始時間: \(sample.startDate), 終了時間: \(sample.endDate)")
//
//        // 例: ローカル通知を表示する
//        DispatchQueue.main.async {
//            let notificationContent = UNMutableNotificationContent()
//            notificationContent.title = "睡眠状態を検出"
//            notificationContent.body = "あなたは現在睡眠中です。時間: \(sample.startDate) - \(sample.endDate)"
//            notificationContent.sound = UNNotificationSound.default
//
//            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
//            let request = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: trigger)
//
//            UNUserNotificationCenter.current().add(request) { error in
//                if let error = error {
//                    print("通知の表示中にエラーが発生しました: \(error.localizedDescription)")
//                }
//            }
//        }
//    }
//
//    // 睡眠していないデータを検出したときに実行される処理
//    func handleAwakeDetected(sample: HKCategorySample) {
//        // ここに睡眠していないときの処理を記述します
//        print("ユーザーが起きています。")
//    }
//
//    // クエリの停止
//    func stopObservingSleepData() {
//        if let query = observerQuery {
//            healthStore.stop(query)
//            print("Observing sleep data stopped")
//        }
//    }
//
//    // デモデータを読み込む
//    func loadDemoData() {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // 2秒後にデモデータを表示
//            self.latestSleepStatus = "Asleep (Demo)"
//            print("デモデータを使用しています")
//        }
//    }
//}
