//
//  RecoverViewModel.swift
//  MyTrack
//
//  Created by Denis Dmitriev on 11.02.2023.
//

import Foundation

class RecoverViewModel {
    
    private var realmService: RealmService
    
    init() {
        self.realmService = RealmService()
    }
    
    func getPassword(by login: String, completion: @escaping ((String?, AppError?) -> Void)) {
        realmService.getPassword(for: login) { (password, error) in
            completion(password, error)
        }
    }
}
