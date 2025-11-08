//
//  Utility.swift
//  YourQuickToDo
//
//  Created by User on 08/11/25.
//

import Foundation

import Foundation
import UIKit
//import FirebaseMessaging
//import MBProgressHUD

class AppUtilityBaseClass: UIViewController {
    
    let currentDate = Date()
    let dateFormatter = DateFormatter()
    override func viewDidLoad() {
        //Perform some task
    }
    /*
    //MARK: Fetch FCM Token.....
    func fetchFCMToken(completion: @escaping (Result<String, Error>) -> Void) {
        Messaging.messaging().token { token, error in
            if let error = error {
                completion(.failure(error))
            } else if let token = token {
                completion(.success(token))
            }
        }
    }
     */

    
    //MARK: Custom UnderLine button......
    func customUnderlineFontButton(btn: UIButton, size: Int, btnTitle: String){
        let customFont = UIFont(name: "Poppins-Medium", size: CGFloat(size))
        let buttonTitle = btnTitle
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: customFont ?? UIFont.systemFont(ofSize: CGFloat(size)),
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: UIColor(named: "ThemeBlue")?.cgColor as Any
        ]
        
        let attributedTitle = NSAttributedString(string: buttonTitle, attributes: attributes)
        btn.setAttributedTitle(attributedTitle, for: .normal)
    }
    
    

    //MARK: show Aleart Message....
    func showCustomAlert(title: String, message: String, viewController: UIViewController, okButtonTitle: String = "OK", okAction: (() -> Void)? = nil, cancelButtonTitle: String? = nil, cancelAction: (() -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: okButtonTitle, style: .default) { _ in
            okAction?()
        }
        alert.addAction(okAction)
        if let cancelButtonTitle = cancelButtonTitle {
            let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .destructive) { _ in
                cancelAction?()
            }
            alert.addAction(cancelAction)
        }
        viewController.present(alert, animated: true, completion: nil)
    }

    
    
    
    
    
    //MARK: show Tost Message....
    func showToast(message: String, duration: Double, color: UIColor, isTop: Bool) {
        let toastView = UIView()
        toastView.backgroundColor = color
        toastView.layer.cornerRadius = 10
        toastView.clipsToBounds = true
        
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.textColor = .white
        messageLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        toastView.addSubview(messageLabel)
        toastView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(toastView)
        
        if isTop == true {
            // Constraints for toastView
            NSLayoutConstraint.activate([
                toastView.leadingAnchor.constraint(greaterThanOrEqualTo: self.view.leadingAnchor, constant: 20),
                toastView.trailingAnchor.constraint(lessThanOrEqualTo: self.view.trailingAnchor, constant: -20),
                toastView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                messageLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 275),
                messageLabel.leadingAnchor.constraint(equalTo: toastView.leadingAnchor, constant: 10),
                messageLabel.trailingAnchor.constraint(equalTo: toastView.trailingAnchor, constant: -10),
                messageLabel.topAnchor.constraint(equalTo: toastView.topAnchor, constant: 10),
                messageLabel.bottomAnchor.constraint(equalTo: toastView.bottomAnchor, constant: -10)
            ])
        } else {
            // Constraints for toastView
            NSLayoutConstraint.activate([
                toastView.leadingAnchor.constraint(greaterThanOrEqualTo: self.view.leadingAnchor, constant: 20),
                toastView.trailingAnchor.constraint(lessThanOrEqualTo: self.view.trailingAnchor, constant: -20),
                toastView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                toastView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
                messageLabel.leadingAnchor.constraint(equalTo: toastView.leadingAnchor, constant: 10),
                messageLabel.trailingAnchor.constraint(equalTo: toastView.trailingAnchor, constant: -10),
                messageLabel.topAnchor.constraint(equalTo: toastView.topAnchor, constant: 10),
                messageLabel.bottomAnchor.constraint(equalTo: toastView.bottomAnchor, constant: -10)
            ])
        }
        
        // Initial state (hidden)
        toastView.alpha = 0
        
        // Animate to show
        UIView.animate(withDuration: 0.3, animations: {
            toastView.alpha = 1
        }) { _ in
            // Animate to hide after delay
            UIView.animate(withDuration: 0.3, delay: duration, options: .curveEaseOut, animations: {
                toastView.alpha = 0
            }) { _ in
                toastView.removeFromSuperview()
            }
        }
    }
    
    
    //MARK: Shake animation....
    func shakeAnimation(view: UIView){
        // Shake animation
        let shakeAnimation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        shakeAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        shakeAnimation.values = [-15, 15, -10, 10, -5, 5, 0] // Shake effect
        shakeAnimation.duration = 0.5
        view.layer.add(shakeAnimation, forKey: "shake")
        
        // Vibration effect (optional)
//        let vibrationAnimation = CABasicAnimation(keyPath: "transform.rotation")
//        vibrationAnimation.fromValue = -0.05
//        vibrationAnimation.toValue = 0.05
//        vibrationAnimation.autoreverses = true
//        vibrationAnimation.duration = 0.1
//        vibrationAnimation.repeatCount = 3
//        view.layer.add(vibrationAnimation, forKey: "vibrate")
    }
    
    
    func showRedView(view: UIView){
        view.layer.borderWidth = 0.3
        view.layer.borderColor = UIColor.red.cgColor
        shakeAnimation(view: view)
    }
    
    func showClearView(view: UIView){
        view.layer.borderColor = UIColor.clear.cgColor
    }
    
    
    func setUpActionButtonConfigure(btn: UIButton) {
        btn.layer.cornerRadius = btn.frame.height / 2
        btn.clipsToBounds = true
    }
    /*
    //MARK: Call Delet User API.....
    func callDeleteUserAPI() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        DeletUserVM.shared.deleteUserCall(){ result in
            DispatchQueue.main.async {
                switch result {
                case .success(let value):
                    print(value)
                    DeletUserVM.shared.deletUserDM = value
                    let data = DeletUserVM.shared.deletUserDM
                    if data?.success == true {
                        self.showToast(message: value.message ?? AlertMessages.shared.success,
                                       duration: 2.0, color: UIColor.red.withAlphaComponent(0.6),
                                       isTop: false)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            UserDefaults.standard.dashboard = false
                            UserDefaults.standard.removeObject(forKey: "User_LoginToken")
                            UserDefaults.standard.removeObject(forKey: "User_Type")
                            UserDefaults.standard.removeObject(forKey: "User_Name")
                            UserDefaults.standard.removeObject(forKey: "User_Email")
                            UserDefaults.standard.removeObject(forKey: "User_Id")
                            UserDefaults.standard.removeObject(forKey: "User_LoginToken")
                            UserDefaults.standard.removeObject(forKey: "Property_Id")
                            UserDefaults.standard.removeObject(forKey: "Id")
                            UserDefaults.standard.synchronize()
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                    } else {
                        self.showToast(message: value.message ?? AlertMessages.shared.somethingWentWrong,
                                       duration: 1.0, color: UIColor.red.withAlphaComponent(0.6),
                                       isTop: false)
                    }
                    MBProgressHUD.hide(for: self.view, animated: true)
                case.failure(let error):
                    print(error.localizedDescription)
                    self.showCustomAlert(title: AlertMessages.shared.alert,
                                         message: error.localizedDescription,
                                         viewController: self)
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
            }
        }
    }
    */
    //MARK: Top Corner radius....
    func topCornerRadius(view: UIView, value: CGFloat){
        view.layer.cornerRadius = value
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.masksToBounds = true
    }
    
    
   
    
}

