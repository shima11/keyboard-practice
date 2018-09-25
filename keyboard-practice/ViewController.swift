//
//  ViewController.swift
//  keyboard-practice
//
//  Created by Jinsei Shima on 2018/09/23.
//  Copyright © 2018 Jinsei Shima. All rights reserved.
//

import UIKit

import EasyPeasy
import RxSwift
import RxKeyboard

class ViewController: UIViewController {

    var scrollView: UIScrollView = .init()

    var textField: UITextField = .init()
    var sendButton: UIButton = .init()
    var inputContainerView: UIView = .init()

    private var keyboardWindow: UIWindow?

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

//        textField.resignFirstResponder()
//        textField.becomeFirstResponder()

        view.addSubview(scrollView)
        view.addSubview(inputContainerView)

        inputContainerView.addSubview(textField)
        inputContainerView.addSubview(sendButton)

        scrollView.keyboardDismissMode = .interactive

        inputContainerView.backgroundColor = .groupTableViewBackground
        sendButton.setTitle("Send", for: .normal)
        sendButton.setAttributedTitle(
            NSAttributedString(
                string: "Send",
                attributes: [
                    NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14, weight: .bold),
                    NSAttributedStringKey.foregroundColor: UIColor.darkGray
                ]
            ),
            for: .normal
        )
        textField.backgroundColor = .white
        textField.borderStyle = .none


        scrollView.easy.layout(
            Top(),
            Left(),
            Right()
        )

        inputContainerView.easy.layout(
            Top().to(scrollView, .bottom),
            Left(),
            Right(),
            Bottom().with(.low)
        )

        textField.easy.layout(
            Top(8),
            Left(8),
            Bottom(8)
        )

        sendButton.easy.layout(
            CenterY().to(textField),
            Left(8).to(textField, .right),
            Right(8)
        )


        RxKeyboard.instance.visibleHeight
            .drive(onNext: { [weak self] keyboardVisibleHeight in
                guard let `self` = self else { return }
                if #available(iOS 11.0, *) {
                    self.inputContainerView.easy.layout(
                        Bottom(keyboardVisibleHeight).to(self.view.safeAreaLayoutGuide, .bottom)
                    )
                } else {
                    self.inputContainerView.easy.layout(
                        Bottom(keyboardVisibleHeight).to(self.bottomLayoutGuide, .top)
                    )
                }
                self.view.setNeedsLayout()
                UIView.animate(withDuration: 0) {
                    self.scrollView.contentInset.bottom = keyboardVisibleHeight + self.inputContainerView.bounds.height
                    self.scrollView.scrollIndicatorInsets.bottom = self.scrollView.contentInset.bottom
                    self.view.layoutIfNeeded()
                }
                print("content inset:", self.scrollView.contentInset)
            })
            .disposed(by: disposeBag)

        RxKeyboard.instance.willShowVisibleHeight
            .drive(onNext: { keyboardVisibleHeight in
                self.scrollView.contentOffset.y += keyboardVisibleHeight
                print("content offset y:", self.scrollView.contentInset)
            })
            .disposed(by: disposeBag)



        NotificationCenter
            .default
            .addObserver(
                self,
                selector: #selector(keyboardWillShow(notification:)),
                name: Notification.Name.UIKeyboardWillShow,
                object: nil
        )

        NotificationCenter
            .default
            .addObserver(
                self,
                selector: #selector(keyboardDidShow(notification:)),
                name: Notification.Name.UIKeyboardDidShow,
                object: nil
        )

        NotificationCenter
            .default
            .addObserver(
                self,
                selector: #selector(keyboardWillDismiss(notification:)),
                name: Notification.Name.UIKeyboardWillHide,
                object: nil
        )

        NotificationCenter
            .default
            .addObserver(
                self,
                selector: #selector(keyboardDidDismiss(notification:)),
                name: Notification.Name.UIKeyboardDidHide,
                object: nil
        )

        NotificationCenter
            .default
            .addObserver(
                self,
                selector: #selector(keyboardWilLChangeFrame(notification:)),
                name: Notification.Name.UIKeyboardWillChangeFrame,
                object: nil
        )

        NotificationCenter
            .default
            .addObserver(
                self,
                selector: #selector(keyboardDidChangeFrame(notification:)),
                name: Notification.Name.UIKeyboardDidChangeFrame,
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

