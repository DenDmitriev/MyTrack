//
//  UserViewController.swift
//  MyTrack
//
//  Created by Denis Dmitriev on 07.02.2023.
//

import UIKit

class UserViewController: UIViewController {
    
    var onLogout: (() -> Void)?
    var toTrack: ((String) -> Void)?
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func toTrackDidTaped(_ sender: UIButton) {
        toTrack?("👾 Some Value")
    }
    
    @IBAction func logoutDidTaped(_ sender: UIButton) {
        UserDefaults.standard.set(false, forKey: "isLogin")
        onLogout?()
    }
}
