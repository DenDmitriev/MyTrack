//
//  AuthViewController.swift
//  MyTrack
//
//  Created by Denis Dmitriev on 07.02.2023.
//

import UIKit
import RxSwift
import RxCocoa

class AuthViewController: UIViewController {
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passTextFiled: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registrationButton: UIButton!
    
    var onLogin: ((User) -> Void)?
    var onRecover: (() -> Void)?
    
    var viewModel: AuthViewModel?
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = AuthViewModel()
        
        configureBindings()
    }
    
    func configureBindings() {
        Observable
            .combineLatest(loginTextField.rx.text, passTextFiled.rx.text)
            .map { login, password in
                return  !(login ?? "").isEmpty && (password ?? "").count >= 6
            }
            .bind { [weak self] inputField in
                self?.loginButton?.isEnabled = inputField
                self?.registrationButton.isEnabled = inputField
            }.disposed(by: disposeBag)
        
        Session.shared.isPrivateApp
            .bind { [weak self] isPrivate in
                self?.loginTextField?.isHidden = !isPrivate
                self?.passTextFiled?.isHidden = !isPrivate
            }.disposed(by: disposeBag)
    }

    fileprivate func presentAlert(_ error: AppError) {
        let alert = UIAlertController(title: error.title, message: error.description, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel)
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    @IBAction func registDidTaped(_ sender: UIButton) {
        guard
            let login = loginTextField.text,
            let password = passTextFiled.text
        else { return }
        
        viewModel?.register(login: login, password: password) { [weak self] (user, error) in
            if let error = error {
                self?.presentAlert(error)
            } else {
                guard let user = user else { return }
                UserDefaults.standard.set(true, forKey: "isLogin")
                self?.onLogin?(user)
            }
        }
    }

    
    @IBAction func loginDidTaped(_ sender: UIButton) {
        guard
            let login = loginTextField.text,
            let password = passTextFiled.text
        else {
            return
        }
        
        viewModel?.auth(login: login, password: password, completion: { [weak self] (user, error) in
            if let error = error {
                self?.presentAlert(error)
            } else {
                guard let user = user else { return }
                UserDefaults.standard.set(true, forKey: "isLogin")
                self?.onLogin?(user)
            }
        })
    }
    
    @IBAction func restoreDidTaped(_ sender: Any) {
        onRecover?()
    }

}
