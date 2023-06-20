//
//  Session.swift
//  MyTrack
//
//  Created by Denis Dmitriev on 03.02.2023.
//

import UIKit
import RxSwift

class Session {
    
    static let shared = Session()
    
    var isTracking: BehaviorSubject<Bool?> = BehaviorSubject(value: nil)
    
    enum Style: Int {
        case walk, run, bicycle
    }
    
    var style: Style = .walk
    
    var isPrivateApp = BehaviorSubject(value: true)
    
    private init() {}
}
