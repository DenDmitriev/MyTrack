//
//  RecoverViewController.swift
//  MyTrack
//
//  Created by Denis Dmitriev on 07.02.2023.
//

import UIKit
import RxSwift
import RxCocoa

class RecoverViewController: UIViewController {
    
    var viewModel: RecoverViewModel?
    let disposeBag = DisposeBag()

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = RecoverViewModel()
        configureBindings()
    }
    
    private func configureBindings() {
        loginTextField.rx.text
            .asObservable()
            .map { login in
                return !(login ?? "").isEmpty
            }
            .bind { [weak loginButton] inputField in
                loginButton?.isEnabled = inputField
            }
            .disposed(by: disposeBag)
        
        Session.shared.isPrivateApp.bind { [weak loginTextField] isPrivate in
            loginTextField?.isHidden = !isPrivate
        }
        .disposed(by: disposeBag)
    }
    
    fileprivate func presentAlert(_ error: AppError) {
        let alert = UIAlertController(title: error.title, message: error.description, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel)
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    @IBAction func restoreDidTaped(_ sender: UIButton) {
        guard
            let login = loginTextField.text
        else { return }
        
        viewModel?.getPassword(by: login, completion: { [weak self] (password, error) in
            if let error = error {
                self?.presentAlert(error)
            } else {
                self?.showPassword(password: password ?? "N/A")
            }
        })
    }
    
    private func showPassword(password: String) {
        let alert = UIAlertController(title: "You password", message: password, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel)
        alert.addAction(action)
        present(alert, animated: true)
    }

}
