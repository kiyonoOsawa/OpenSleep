//
//  UsingView.swift
//  OpenSleep
//
//  Created by 大澤清乃 on 2024/09/21.
//

import SwiftUI
import HealthKit
import HealthKitUI
import AVFoundation

struct UsingView: View {
    @StateObject private var checkNeochi = CheckNeochi()
    
    @Environment(\.dismiss) private var dismiss
    
    let synthesizer = AVSpeechSynthesizer()
    
    var body: some View {
        VStack {
            Text("授業中・・・")
                .padding()
            
            Button(action: {
                print("授業終了")
                // ここに授業終了時の処理を追加
                checkNeochi.stopObservingSleepData()
                dismiss()
                
            }, label: {
                Text("授業終了")
                    .frame(width: 300, height: 56)
                    .background(Color.mainColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            })
        }
        .padding()
        .task {
            // 初回起動時の処理：アクセス許可と監視を開始
            checkNeochi.checkPermistion()
        }
        .onAppear {
            //ユーザのデータを取得
            let userData = UsingStudentData().loadUserDefaultsData() // 画面表示時にデータを読み込む
            print("🥰\(userData.schoolID)")
            let schoolID = userData.schoolID
            let name = userData.name
            checkNeochi.loadDemoData(schoolID: schoolID, name: name)  //デモデータを使用
            checkNeochi.startObservingSleepData(schoolID: schoolID, name: name)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(
                    action: {
                        dismiss()
                    }, label: {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("back")
                        }
                    }
                ).tint(Color.mainColor)
            }
        }
    }
}

#Preview {
    UsingView()
}
