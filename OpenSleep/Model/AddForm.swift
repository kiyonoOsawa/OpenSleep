//
//  AddForm.swift
//  OpenSleep
//
//  Created by 大澤清乃 on 2024/09/22.
//

import Foundation
import Firebase
import FirebaseFirestore

class AddForm: ObservableObject {
    
    @Published private var savedDataID: String {
        didSet {
            // 配列の内容をUserDefaultsに保存
            UserDefaults.standard.set(savedDataID, forKey: "schoolID")
        }
    }
    
    @Published private var savedDataStudent: String {
        didSet {
            // 配列の内容をUserDefaultsに保存
            UserDefaults.standard.set(savedDataStudent, forKey: "studentName")
        }
    }
    
    init() {
        // UserDefaultsからデータを読み込む
        if let schoolID = UserDefaults.standard.array(forKey: "schoolID") as? String {
            self.savedDataID = schoolID
        } else {
            self.savedDataID = ""
        }
        
        if let studentName = UserDefaults.standard.array(forKey: "studentName") as? String {
            self.savedDataStudent = studentName
        } else {
            self.savedDataStudent = ""
        }
    }
    
    func saveSchoolID(_ schoolID: String) {
        savedDataID.append(schoolID)
        print("データが保存されました: \(schoolID)")
    }
    
    // データを保存するメソッド
    func saveStudentName(_ studentName: String) {
        savedDataStudent.append(studentName)
        print("データが保存されました: \(studentName)")
    }
    
    let db = Firestore.firestore()
    var date = Date()
    
    func addData(studentName: String, studentNum: String, checkNeru: Bool) {
        let convertedDate = Timestamp(date: date)
        let addData: [String:Any] = [
            "name": studentName,
            "number": studentNum,
            "date": convertedDate,
            "isSleep": checkNeru
        ]
        
        db.collection("classes")
            .addDocument(data: addData)
    }
}
