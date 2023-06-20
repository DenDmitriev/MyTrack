//
//  Track.swift
//  MyTrack
//
//  Created by Denis Dmitriev on 02.02.2023.
//

import Foundation
import RealmSwift

class Track: Object {
    @Persisted var startTime: Date = Date.now
    @Persisted var finishTime: Date = Date.now + 1
    @Persisted var distance: Double = 0.0
    @Persisted var locations: List<Location>
}
