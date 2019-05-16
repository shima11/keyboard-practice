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


class KeyboardObserver {
    
    // KeyboardWindowだけを抽出する機能

    private var changeHandler: ((UIWindow) -> Void)?
    
    func getKeybaordWindow(changeHandler: @escaping (UIWindow) -> Void) {
        
        self.changeHandler = changeHandler
        
        NotificationCenter
            .default
            .addObserver(
                self,
                selector: #selector(keyboardWillShow(notification:)),
                name: UIResponder.keyboardWillShowNotification,
                object: nil
        )
    }

    @objc func keyboardWillShow(notification: Notification) {
        
        guard
            let _keyboardWindow = UIApplication.shared.windows.filter({ window in
                guard let name = NSClassFromString("UIRemoteKeyboardWindow") else { return false }
                return window.isKind(of: name)
            }).first
        else { return }
        
        changeHandler?(_keyboardWindow)
    }

}

// memo:
//
// UIView.performWithoutAnimation {}
//
// CATransaction.begin()
// CATransaction.setDisableActions(true)
// keyboardWindow?.layoutSubviews()
// CATransaction.commit()


class ViewController: UIViewController {
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    let inputContainerView: UIView = .init()
    
    let inputContentView: UIView = .init()
    let textField: UITextField = .init()
    let sendButton: UIButton = .init()
    
    private let keyboardObserver = KeyboardObserver()
    
    private var keyboardWindow: UIWindow?
    private var keyboardHeight: CGFloat?
    private var currentOffsetY: CGFloat = 0
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {

        super.viewDidLoad()

        view.backgroundColor = .white

        view.addSubview(collectionView)
        view.addSubview(inputContainerView)

        inputContainerView.addSubview(inputContentView)
        inputContentView.addSubview(textField)
        inputContentView.addSubview(sendButton)

        prepare: do {
            
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
            
        }
        
        layout: do {
            
            collectionView.easy.layout(Edges())
            
            inputContainerView.easy.layout(
                Left(),
                Bottom(),
                Right()
            )
            
            inputContentView.easy.layout(
                Top(),
                Left(),
                Right(),
                Bottom().to(view.safeAreaLayoutGuide, .bottom)
            )
            
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

        }
        
        bind: do {
            
            keyboardObserver
                .getKeybaordWindow(changeHandler: { [weak self] window in
                    print(window)
                    if self?.keyboardWindow == nil {
                        self?.keyboardWindow = window
                    }
                })
            
            RxKeyboard
                .instance
                .willShowVisibleHeight
                .drive(onNext: { keyboardVisibleHeight in
                    self.keyboardHeight = keyboardVisibleHeight
                    self.collectionView.contentOffset.y += keyboardVisibleHeight
//                print("++++", keyboardVisibleHeight)
                })
                .disposed(by: disposeBag)
            
            RxKeyboard
                .instance
                .visibleHeight
                .drive(onNext: { [weak self] keyboardVisibleHeight in
                    guard let `self` = self else { return }
                    self.inputContentView.easy.layout(
                        Bottom(keyboardVisibleHeight)
                            .to(self.view.safeAreaLayoutGuide, .bottom)
                            .when({ return keyboardVisibleHeight <= 0 }),
                        Bottom(keyboardVisibleHeight)
                            .when({ return keyboardVisibleHeight > 0 })
                    )
                    self.view.setNeedsLayout()
                    UIView.animate(withDuration: 0) {
                        let bottomInset = keyboardVisibleHeight + self.inputContentView.bounds.height
                        self.collectionView.contentInset.bottom = bottomInset
                        self.collectionView.scrollIndicatorInsets.bottom = bottomInset
                        self.view.layoutIfNeeded()
                    }
                    print("****", keyboardVisibleHeight)
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
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showWindowInfo(notification: nil, isDisplay: false, label: "view did appear")
    }

    override func updateViewConstraints() {
        print("::::update view constraints")
        super.updateViewConstraints()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        print("::::view did layout subviews")
        if collectionView.contentInset.bottom <= 0 {
            collectionView.contentInset.bottom = inputContentView.bounds.height
            collectionView.scrollIndicatorInsets.bottom = collectionView.contentInset.bottom
        }
                super.viewDidLayoutSubviews()
    }

    @objc func keyboardWillShow(notification: Notification) {
        showWindowInfo(notification: notification, isDisplay: false, label: "will show")
    }
    
    @objc func keyboardDidShow(notification: Notification) {
        showWindowInfo(notification: notification, isDisplay: false, label: "did show")
    }

    @objc func keyboardWillDismiss(notification: Notification) {
        showWindowInfo(notification: notification, isDisplay: false, label: "will dismiss")
    }

    @objc func keyboardDidDismiss(notification: Notification) {
        showWindowInfo(notification: notification, isDisplay: false, label: "did dismiss")
    }

    @objc func keyboardWilLChangeFrame(notification: Notification) {
        showWindowInfo(notification: notification, isDisplay: false, label: "will change frame")
    }

    @objc func keyboardDidChangeFrame(notification: Notification) {
        showWindowInfo(notification: notification, isDisplay: false, label: "did change frame")
    }
    
    private func showWindowInfo(notification: Notification?, isDisplay: Bool = true, label: String) {
        
        guard isDisplay else { return }

        print("=======================================", label)

        let windows = UIApplication.shared.windows
        
        print("notification:", notification ?? "nil")
        print("windows:\(windows.count)\n", windows)
        print("key window:", UIApplication.shared.keyWindow ?? "nil")
        
        // UIWindow, UITextEffectsWindow, UIRemoteKeyboardWindow
        
        windows.forEach { window in
            guard let name = NSClassFromString("UIRemoteKeyboardWindow") else { return }
            print("is keyboard window:", window.isKind(of: name))
        }
        print("=======================================")
    }
}

// MARK: - UICollectionViewDelegate

extension ViewController: UICollectionViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        currentOffsetY = scrollView.contentOffset.y
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if isScrollViewButton(scrollView: scrollView) {
            // キーボードの表示アニメーションなし
            UIView.performWithoutAnimation {
                textField.becomeFirstResponder()
            }
        }
        
        // TODO: keyboard
        
//        if let layer = keyboardWindow?.layer, let height = keyboardHeight, isButtom == true {
//            let progress = (scrollView.contentOffset.y - currentOffsetY) / height
//            print("progress:", progress)
//            setProgressLayer(layer: layer, progress: progress)
//        }
        
    }
    
    private func isScrollViewButton(scrollView: UIScrollView) -> Bool {
        
        return (scrollView.contentOffset.y + scrollView.bounds.height - scrollView.contentInset.top - scrollView.contentInset.bottom) >= scrollView.contentSize.height
    }

    private func setProgressLayer(layer: CALayer, progress: CGFloat) {
        layer.timeOffset = Double(progress)
        layer.beginTime = layer.convertTime(CACurrentMediaTime(), from: nil)
    }
    
}

// MARK: - UICollectionViewDataSource

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

// MARK: - UICollectionVeiwDelegateFlowLayout

extension ViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 60)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
}


