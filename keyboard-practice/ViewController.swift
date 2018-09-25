//
//  ViewController.swift
//  keyboard-practice
//
//  Created by Jinsei Shima on 2018/09/23.
//  Copyright © 2018 Jinsei Shima. All rights reserved.
//

// https://dev.classmethod.jp/smartphone/ios-uiwindow/

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var textField: UITextField!

    private var keyboardWindow: UIWindow?

    override func viewDidLoad() {
        super.viewDidLoad()

//        textField.resignFirstResponder()
//        textField.becomeFirstResponder()

        scrollView.keyboardDismissMode = .interactive

        NotificationCenter
            .default
            .addObserver(
                self,
                selector: #selector(keyboardWillShow(notification:)),
                name: UIResponder.keyboardWillShowNotification,
                object: nil
        )

        NotificationCenter
            .default
            .addObserver(
                self,
                selector: #selector(keyboardDidShow(notification:)),
                name: UIResponder.keyboardDidShowNotification,
                object: nil
        )

        NotificationCenter
            .default
            .addObserver(
                self,
                selector: #selector(keyboardWillDismiss(notification:)),
                name: UIResponder.keyboardDidHideNotification,
                object: nil
        )

        NotificationCenter
            .default
            .addObserver(
                self,
                selector: #selector(keyboardDidDismiss(notification:)),
                name: UIResponder.keyboardDidHideNotification,
                object: nil
        )

        NotificationCenter
            .default
            .addObserver(
                self,
                selector: #selector(keyboardWilLChangeFrame(notification:)),
                name: UIResponder.keyboardWillChangeFrameNotification,
                object: nil
        )

        NotificationCenter
            .default
            .addObserver(
                self,
                selector: #selector(keyboardDidChangeFrame(notification:)),
                name: UIResponder.keyboardDidChangeFrameNotification,
                object: nil
        )
        
    }

    private func showWindowInfo() {
        let windows = UIApplication.shared.windows
        print("windows:\(windows.count)\n", windows)
        print("key window:", UIApplication.shared.keyWindow ?? "nil")

        // UIWindow, UITextEffectsWindow, UIRemoteKeyboardWindow

        windows.forEach { window in
            guard let name = NSClassFromString("UIRemoteKeyboardWindow") else { return }
            print("is keyboard:", window.isKind(of: name))
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showWindowInfo()
    }

    override func updateViewConstraints() {
        print("update view constraints")
        super.updateViewConstraints()
    }

    override func viewDidLayoutSubviews() {
        print("view did layout subviews")
        super.viewDidLayoutSubviews()
    }


    @objc func keyboardWillShow(notification: Notification) {
        print("======================================= will")
        print("will show:\n", notification)
        showWindowInfo()

        keyboardWindow = UIApplication.shared.windows
            .filter { window in
                guard let name = NSClassFromString("UIRemoteKeyboardWindow") else { return false }
                return window.isKind(of: name)
            }
            .first

//        keyboardWindow?.layer.speed = 0

    }

    @objc func keyboardDidShow(notification: Notification) {
        print("======================================= did")
        print("did show:\n", notification)
        showWindowInfo()
    }

    @objc func keyboardWillDismiss(notification: Notification) {
        print("======================================= did")
        print("will Dismisss:\n", notification)
        showWindowInfo()
    }

    @objc func keyboardDidDismiss(notification: Notification) {
        print("======================================= did")
        print("did Dismiss:\n", notification)
        showWindowInfo()
    }

    @objc func keyboardWilLChangeFrame(notification: Notification) {
//        print("=======================================")
//        print("will change frame:\n", notification)
    }

    @objc func keyboardDidChangeFrame(notification: Notification) {
//        print("=======================================")
//        print("did change frame:\n", notification)
    }

}

