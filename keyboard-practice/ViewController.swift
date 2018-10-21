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

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    let textField: UITextField = .init()
    let sendButton: UIButton = .init()
    let inputContainerView: UIView = .init()

    private var keyboardWindow: UIWindow?

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

//        textField.resignFirstResponder()
//        textField.becomeFirstResponder()

        view.addSubview(collectionView)
        view.addSubview(inputContainerView)
        inputContainerView.addSubview(textField)
        inputContainerView.addSubview(sendButton)

        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.backgroundColor = .white
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.keyboardDismissMode = .interactive

        inputContainerView.backgroundColor = .white

        sendButton.setAttributedTitle(
            NSAttributedString(
                string: "Send",
                attributes: [
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .bold),
                    NSAttributedString.Key.foregroundColor: UIColor.darkGray
                ]
            ),
            for: .normal
        )
        textField.borderStyle = .none
        textField.placeholder = "Message text..."

        collectionView.easy.layout(
            Edges()
        )

        if #available(iOS 11.0, *) {
            inputContainerView.easy.layout(
                Left(),
                Right(),
                Bottom().to(view.safeAreaLayoutGuide, .bottom)
            )
        } else {
            inputContainerView.easy.layout(
                Left(),
                Right(),
                Bottom().to(bottomLayoutGuide, .top)
            )
        }

        textField.easy.layout(
            Top(8),
            Left(8),
            Bottom(8),
            Height(40)
        )

        sendButton.easy.layout(
            CenterY().to(textField),
            Left(8).to(textField, .right),
            Right(8)
        )


        RxKeyboard
            .instance
            .willShowVisibleHeight
            .drive(onNext: { keyboardVisibleHeight in
                print("++++", keyboardVisibleHeight)
                self.collectionView.contentOffset.y += keyboardVisibleHeight
                print("content offset y:", self.collectionView.contentInset)
            })
            .disposed(by: disposeBag)

        RxKeyboard
            .instance
            .visibleHeight
            .drive(onNext: { [weak self] keyboardVisibleHeight in
                print("****", keyboardVisibleHeight)
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
                    let bottomInset = keyboardVisibleHeight + self.inputContainerView.bounds.height
                    self.collectionView.contentInset.bottom = bottomInset
                    self.collectionView.scrollIndicatorInsets.bottom = bottomInset
                    self.view.layoutIfNeeded()
                }
                print("content inset:", self.collectionView.contentInset)
            })
            .disposed(by: disposeBag)

        
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
                name: UIResponder.keyboardWillHideNotification,
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
            print("is keyboard window:", window.isKind(of: name))
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showWindowInfo()
    }

    override func updateViewConstraints() {
        print("::::update view constraints")
        super.updateViewConstraints()
    }

    override func viewDidLayoutSubviews() {
        print("::::view did layout subviews")
        super.viewDidLayoutSubviews()

        if collectionView.contentInset.bottom == 0 {
            collectionView.contentInset.bottom = inputContainerView.bounds.height
            collectionView.scrollIndicatorInsets.bottom = collectionView.contentInset.bottom
        }
    }


    @objc func keyboardWillShow(notification: Notification) {
        print("======================================= will show")
        print(notification)
        showWindowInfo()

        keyboardWindow = UIApplication.shared.windows
            .filter { window in
                guard let name = NSClassFromString("UIRemoteKeyboardWindow") else { return false }
                return window.isKind(of: name)
            }
            .first

//        keyboardWindow?.layer.speed = 0
        print("=======================================")
    }

    @objc func keyboardDidShow(notification: Notification) {
        print("======================================= did show")
        print(notification)
        showWindowInfo()
        print("=======================================")
    }

    @objc func keyboardWillDismiss(notification: Notification) {
        print("======================================= will dismiss")
        print(notification)
        showWindowInfo()
        print("=======================================")
    }

    @objc func keyboardDidDismiss(notification: Notification) {
        print("======================================= did dismiss")
        print(notification)
        showWindowInfo()
        print("=======================================")
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

extension ViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let inputView = UIView()
        inputView.backgroundColor = .lightGray
        inputView.layer.cornerRadius = 8
        inputView.clipsToBounds = true
        cell.addSubview(inputView)
        inputView.easy.layout(
            Left(8),
            Top(8),
            Right(8),
            Bottom(8)
        )
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }

}

extension ViewController: UICollectionViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset.y, scrollView.bounds.height, scrollView.contentInset.top, scrollView.contentInset.bottom, scrollView.contentSize.height)
        if scrollView.contentOffset.y + scrollView.bounds.height - scrollView.contentInset.top - scrollView.contentInset.bottom >= scrollView.contentSize.height {
            print("scroll to bottom")
        }
    }

}

extension ViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 60)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
}


