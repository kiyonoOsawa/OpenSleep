//
//  TimeModel.swift
//  OpenSleep
//
//  Created by 大澤清乃 on 2024/09/21.
//

import Foundation

class TimeModel: ObservableObject {
    let startHour: [Int] = [9, 11, 13, 14, 16, 18]
    let startMin: [Int] = [25, 10, 00, 45, 30, 10]
    let endHour: [Int] = [10, 12, 14, 16, 18, 19]
    let endMin: [Int] = [55, 40, 30, 15, 00, 40]
}
