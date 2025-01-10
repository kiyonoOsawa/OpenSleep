//
//  OpenCamera.swift
//  OpenSleep
//
//  Created by 大澤清乃 on 2024/09/22.
//

import Foundation
import UIKit

class OpenCamera: ObservableObject {
    func openCameraApp() {
        // カメラアプリのURLスキーム
        if let cameraURL = URL(string: "camera://") {
            if UIApplication.shared.canOpenURL(cameraURL) {
                UIApplication.shared.open(cameraURL, options: [:], completionHandler: nil)
            } else {
                print("カメラアプリが起動できません")
            }
        }
    }
}
