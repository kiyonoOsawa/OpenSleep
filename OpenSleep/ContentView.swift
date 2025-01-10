//
//  ContentView.swift
//  OpenSleep
//
//  Created by 大澤清乃 on 2024/09/21.
//

import SwiftUI

struct ContentView: View {
    @State private var showMakeQR: Bool = false
    @State private var qrImage: UIImage?
    @State private var showUsing: Bool = false
    
    @StateObject private var checkNeochi = CheckNeochi()
    
    @Binding var showFormView: Bool
    @Binding var teacherName: String?
    @Binding var classTime: String?
    
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    if ((qrImage) != nil) {
                        Image(uiImage: qrImage ?? UIImage())
                            .resizable()
                            .interpolation(.none) // 高品質の表示
                            .scaledToFit()
                            .frame(width: 300, height: 300)
                            .padding()
                    } else {
                        Image(uiImage: UIImage(named: "OpenSleep")!)
                            .resizable()
                            .interpolation(.none) // 高品質の表示
                            .scaledToFit()
                            .frame(width: 300, height: 300)
                            .padding()
                    }
                }
                .task {
                    do {
                        checkNeochi.checkPermistion()
                    }
                }
                .padding()
                
                VStack {
                    Button(action: {
                        print("画面遷移")
                        showMakeQR.toggle()
                    }, label: {
                        Text("QRコードを作成")
                            .frame(width: 300, height: 64)
                            .background(.white)
                            .fontWeight(.bold)
                            .font(.system(size: 16))
                            .foregroundColor(Color.mainColor)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.mainColor, lineWidth: 4)
                            )
                    })
                    .sheet(isPresented: $showMakeQR) {
                        MakeQRCode(qrImage: $qrImage)
                    }
                }
                .sheet(isPresented: $showFormView, onDismiss: {
                    // `firstView`がdismissされた後に`navigateToSecondView`をtrueにします
                    showUsing = true
                }) {
                    FormView(getTeacherName: $teacherName, getClassTime: $classTime)
                }
                
                NavigationLink(
                    destination: UsingView(),
                    isActive: $showUsing
                ) {
                    Text("")
                }
            }
        }
    }
}

extension Color {
    static let mainColor = Color("MainColor")
    static let grayColor = Color("GrayColor")
}
