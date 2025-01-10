import SwiftUI

struct FormView: View {
    
    @State private var inputNumber: String = ""
    @State private var inputMyName: String = ""
//    @State private var showView: Bool = false
    
    @StateObject private var checkNeochi = CheckNeochi()
    
    @Binding var getTeacherName: String?
    @Binding var getClassTime: String?
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.grayColor.ignoresSafeArea()
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            var classNum = Int(getClassTime!)
//                            checkNeochi.timeSetting(classNum: classNum ?? 1)
                            AddForm().addData(studentName: inputMyName, studentNum: inputNumber, checkNeru: false)
                            AddForm().saveSchoolID(inputNumber)
                            AddForm().saveStudentName(inputMyName)
                            dismiss()

                        }, label: {
                            Text("提出")
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
                    
                    HStack {
                        Text("教師名: \(getTeacherName ?? "不明")")
                            .padding(.leading, 8)
                            .font(.system(size: 16))
                        Spacer()
                    }
                    .background(.white)
                    .frame(width: 360, height: 52)
                    .background(.white)
                    .cornerRadius(8)
                    HStack {
                        Text("授業時間: \(getClassTime ?? "不明")")
                            .padding(.leading, 8)
                            .font(.system(size: 16))
                        Spacer()
                    }
                    .background(.white)
                    .frame(width: 360, height: 52)
                    .background(.white)
                    .cornerRadius(8)
                    TextField("学籍番号を入力", text: $inputNumber)
                        .background(.white)
                        .frame(width: 352, height: 52)
                        .padding(.leading, 8)
                        .background(.white)
                        .cornerRadius(8)
                        .font(.system(size: 16))
                    TextField("名前を入力", text: $inputMyName)
                        .background(.white)
                        .frame(width: 352, height: 52)
                        .padding(.leading, 8)
                        .background(.white)
                        .cornerRadius(8)
                        .font(.system(size: 16))
                    Spacer()
                }
            }
        }
    }
}

//#Preview {
//    // プレビュー用のサンプルデータ
//    FormView(getTeacherName: , getClassTime: "b")
//}
