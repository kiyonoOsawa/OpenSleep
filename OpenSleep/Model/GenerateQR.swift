import Foundation
import UIKit
import CoreImage.CIFilterBuiltins // QRコードの生成に必要

class GenerateQR {
    static let shared = GenerateQR()
    
    // URLを作成する関数
    func createURL(with teacherName: String, classTime: String) -> URL? {
        var components = URLComponents()
        components.scheme = "op-app"
        components.host = "app"
        components.path = "/"
        components.queryItems = [
            URLQueryItem(name: "teacherName", value: teacherName),
            URLQueryItem(name: "classTime", value: classTime)
        ]
        print("ここはどうですか\(components.queryItems)")
        print("🐶\(components)")
        return components.url
    }
    
    // URLからQRコードを生成する関数
    func generateQRCode(from url: URL) -> UIImage? {
        let urlString = url.absoluteString
        let data = Data(urlString.utf8)
        
        let filter = CIFilter.qrCodeGenerator()
        filter.setValue(data, forKey: "inputMessage")
        
        if let outputImage = filter.outputImage {
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let scaledImage = outputImage.transformed(by: transform)
            
            let context = CIContext()
            if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        return nil
    }
}
