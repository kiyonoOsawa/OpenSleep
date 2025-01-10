//
//  MakeQRCode.swift
//  OpenSleep
//
//  Created by 大澤清乃 on 2024/09/21.
//

import SwiftUI

struct MakeQRCode: View {
    @State private var inputName = ""
    @State private var selectedTime: String = ""
    @Binding var qrImage: UIImage? // QRコード画像をContentViewに渡すためのバインディング
    
    @StateObject private var classTime = ClassTime()
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.grayColor.ignoresSafeArea()
            VStack {
                HStack() {
                    Spacer()
                    Button(action: {
                        // データを一旦保存
                        QRData().saveIdData(inputName)
                        QRData().saveClassData(selectedTime)
                        //QRコード生成
                        if let url = GenerateQR.shared.createURL(with: inputName, classTime: selectedTime) {
                            qrImage = GenerateQR.shared.generateQRCode(from: url)
                            dismiss()
                            print("👿\(url)")
                        }
                        
//                        dismiss()
                    }, label: {
                        Text("作成")
                            .fontWeight(.bold)
                            .font(.system(size: 20))
                            .cornerRadius(12)
                            .foregroundColor(Color.mainColor)
                            .padding(.trailing)
                    })
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(.white)
                
                VStack(spacing: 16) {
                    TextField("教授用CNSアカウント", text: $inputName)
                        .background(.white)
                        .frame(width: 352, height: 52)
                        .padding(.leading, 8)
                        .background(.white)
                        .cornerRadius(8)
                        .font(.system(size: 16))
                    
                    HStack {
                        Picker("Select a fruit", selection: $selectedTime) {
                            ForEach(classTime.classNumber, id: \.self) { number in
                                Text(number).tag(number)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(.leading, 48)
                        Spacer()
                        Text("限")
                            .padding(.trailing, 48)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                    }
                    .frame(width: 360, height: 52)
                    .background(.white)
                    .cornerRadius(8)
                }
                .padding(.top, 12)
                Spacer()
            }
        }
    }
}

#Preview {
    MakeQRCode(qrImage: .constant(nil))
}
