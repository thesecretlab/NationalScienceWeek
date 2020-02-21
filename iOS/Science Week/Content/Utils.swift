//
//  Utils.swift
//  Science Week
//
//  Created by Mars Geldard on 18/6/19.
//  Copyright © 2019 Mars Geldard. All rights reserved.
//

import os.log
import WebKit

class Logger {
    
    private init() {}
    
    static func log(_ message: String,  type: OSLogType = OSLogType.info) {
        os_log("%@", log: OSLog.default, type: .info, message)
    }
}

// MARK: UI Element utilities

extension UITabBar {
    
    func setBackgroundColor(colour: UIColour) {
        
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()!.setFillColor(colour.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.backgroundImage = colorImage
    }
}

extension UIViewController {
    func showToast(message: String, image: UIImage? = nil, seconds: Double = 0.3) {
        let alert = UIAlertController(message: message)
        
        self.present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            alert.dismiss(animated: true)
        }
    }
    
    func summonAlertView(message: String? = nil) {
        let alertController = UIAlertController(
            title: "Error",
            message: message ?? "Action could not be completed.",
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
}

extension UIAlertController {
    convenience init(message: String, image: UIImage? = nil) {
        self.init(title: nil, message: message, preferredStyle: .alert)
        
        if let alertContentView = self.view.subviews.first?.subviews.first {
            alertContentView.backgroundColor = Theme.lightTheme ? .white : .black
            alertContentView.layer.cornerRadius = 15
        }

        self.view.tintColor = Theme.lightTheme ? .black : .white
        
        if let image = image {
            self.setValue(image, forKey: "image")
        }
    }
}

extension UIColour {
    public typealias StringLiteralType = String
    
    var cgColour: CGColor { return self.cgColor }
    
    convenience init(r red: CGFloat, g green: CGFloat, b blue: CGFloat, a alpha: CGFloat = 1.0 ) {
        self.init(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
    }
    
    public convenience init(hex: String) {
        var string = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        string = string.trimmingCharacters(in: CharacterSet(["#"]))
        var rgbValue: UInt32 = 0
        
        if string.count == 6 {
            Scanner(string: string).scanHexInt32(&rgbValue)
            
            self.init(
                red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: CGFloat(1.0)
            )
        } else {
            self.init(red: 0, green: 0, blue: 0, alpha: 0)
        }
        
    }
    
    func lightened(by percentage: CGFloat = 30.0) -> UIColour {
        return self.adjust(by: abs(percentage)) ?? UIColour.white
    }
    
    func darkened(by percentage: CGFloat = 30.0) -> UIColour {
        return self.adjust(by: -1 * abs(percentage)) ?? UIColour.black
    }
    
    func adjust(by percentage: CGFloat = 30.0) -> UIColour? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColour(red: min(red + percentage/100, 1.0),
                           green: min(green + percentage/100, 1.0),
                           blue: min(blue + percentage/100, 1.0),
                           alpha: alpha)
        }
        
        return nil
    }
}

// MARK: WebKit utilities

extension WKWebView {
    
    // check if webview is blank by seeing if the body HTML is empty
    func isBlank() -> Bool {
        var body: Any?
        var error: Error?
        
        self.evaluateJavaScript("document.querySelector('body').innerHTML") { (contentResponse, errorResponse) in
            body = contentResponse
            error = errorResponse
        }
        
        return (error != nil || body == nil)
    }
    
    // get content of webpage
    func getContent(completion: @escaping (String?) -> Void) {
        self.evaluateJavaScript("document.documentElement.outerHTML.toString()") { html, error in
            if let html = html as? String, error == nil {
                completion(html)
            } else {
                completion(nil)
            }
        }
    }
}

extension Timer {
    convenience init(seconds: Double, block: @escaping (Timer?) -> Void) {
        self.init(timeInterval: TimeInterval(seconds), repeats: false, block: block)
    }
}
