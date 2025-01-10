//
//  QRData.swift
//  OpenSleep
//
//  Created by 大澤清乃 on 2024/09/21.
//

import Foundation

class QRData: ObservableObject {
    @Published private var savedData: String {
        didSet {
            // 配列の内容をUserDefaultsに保存
            UserDefaults.standard.set(savedData, forKey: "teacherID")
            UserDefaults.standard.set(savedData, forKey: "classID")
        }
    }
    
    init() {
        // UserDefaultsからデータを読み込む
        if let idData = UserDefaults.standard.array(forKey: "teacherID") as? String {
            self.savedData = idData
        } else {
            self.savedData = ""
        }
        
        if let classData = UserDefaults.standard.array(forKey: "classID") as? String {
            self.savedData = classData
        } else {
            self.savedData = ""
        }
    }
    
    // データを保存するメソッド
    func saveIdData(_ idData: String) {
        savedData.append(idData)
        print("データが保存されました: \(idData)")
    }
    
    func saveClassData(_ classData: String) {
        savedData.append(classData)
        print("データが保存されました: \(classData)")
    }
}
