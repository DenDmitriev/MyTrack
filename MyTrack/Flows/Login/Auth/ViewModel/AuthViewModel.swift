//
//  AuthViewModel.swift
//  MyTrack
//
//  Created by Denis Dmitriev on 11.02.2023.
//

import Foundation

class AuthViewModel {
    
    private var realmService: RealmService
    
    init() {
        self.realmService = RealmService()
    }
    
    func register(login: String, password: String, completion: @escaping ((User?, AppError?) -> Void)) {
        realmService.addUser(login: login, password: password) { (user, error) in
            completion(user, error)
        }
    }
    
    func auth(login: String, password: String, completion: @escaping ((User?, AppError?) -> Void)) {
        realmService.verifyUser(login: login, password: password) { user, error in
            completion(user, error)
        }
    }
}
