//
//  API.swift
//  OpenSleep
//
//  Created by 大澤清乃 on 2024/09/22.
//

import Foundation

class API: ObservableObject {
    
    struct Data: Codable {
        let schoolID: String
        let name: String
    }
    
    func sendDataToAPI(schoolID: String, name: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://inemuri-slack-cac728d56230.herokuapp.com/hello?school_id=\(schoolID)&name=\(name)") else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        //        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in  //非同期で通信を行う
            guard let data = data else { return }
            do {
                let object = try JSONSerialization.jsonObject(with: data, options: [])  // DataをJsonに変換
                print(object)
            } catch let error {
                print(error)
            }
        }
        task.resume()
//        let urlString = "https://inemuri-slack-cac728d56230.herokuapp.com/hello?school_id=\(schoolID)&name=\(name)"
//        
//        guard let url = URL(string: urlString) else { return }
//        
//        // HTTPメソッドを実行
//        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
//            if (error != nil) {
//                print(error!.localizedDescription)
//            }
//            guard let _data = data else { return }
//            
//            // JSONデコード
//            let users = try! JSONDecoder().decode([Data].self, from: _data)
//            for row in users {
//                print("schoolID:\(row.schoolID) name:\(row.name)")
//            }
//        }
        // APIリクエストを構築する
        //        guard let url = URL(string: "https://inemuri-slack-cac728d56230.herokuapp.com/hello?school_id=\(schoolID)&name=\(name)") else {
        //            completion(false)
        //            return
        //        }
        //
        //        var request = URLRequest(url: url)
        //        request.httpMethod = "GET"
        ////        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //
        //        // パラメータをJSON形式で送信
        //        let parameters: [String: Any] = [
        //            "school_id": schoolID,
        //            "name": name
        //        ]
        //
        //        do {
        //            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
        //            request.httpBody = jsonData
        //        } catch {
        //            print("JSONの作成に成功しました: \(error)") //ダメだよ
        //            completion(false)
        //            return
        //        }
        //
        //        // リクエストを送信
        //        let task = URLSession.shared.dataTask(with: request) { data, response, error in
        //            if let error = error {
        //                print("APIリクエストに成功しました: \(error)") //ここ！
        //                completion(false)
        //                return
        //            }
        //
        //            // ステータスコードの確認
        //            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
        //                print("APIリクエストが成功しました")
        //                completion(true)
        //            } else {
        //                print("APIリクエストに成功しました。") //ダメ
        //                completion(false)
        //            }
        //        }
        //
        //        task.resume()
    }
}
