//
//  UsingStudentData.swift
//  OpenSleep
//
//  Created by 大澤清乃 on 2024/09/22.
//

import Foundation

class UsingStudentData: ObservableObject {
    // UserDefaultsからデータを取り出す
    func loadUserDefaultsData() -> (schoolID: String, name: String) {
        let savedSchoolID = UserDefaults.standard.string(forKey: "schoolID") ?? "No School ID Found"
        let savedName = UserDefaults.standard.string(forKey: "studentName") ?? "No Name Found"
        
        return (schoolID: savedSchoolID, name: savedName)
    }
}
