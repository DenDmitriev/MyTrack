//
//  User.swift
//  MyTrack
//
//  Created by Denis Dmitriev on 11.02.2023.
//

import Foundation
import RealmSwift

class User: Object {
    @Persisted(primaryKey: true) var login: String
    @Persisted var password: String
    @Persisted var age: Int?
    @Persisted var gender: Bool? //true = male, false = female 🥴
}

