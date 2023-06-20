//
//  Location.swift
//  MyTrack
//
//  Created by Denis Dmitriev on 02.02.2023.
//

import Foundation
import RealmSwift

class Location: Object {
    @Persisted var latitude: Double = 0.0
    @Persisted var longitude: Double = 0.0
    @Persisted var altitude: Double = 0.0
    @Persisted var horizontalAccuracy: Double = 0.0
    @Persisted var verticalAccuracy: Double = 0.0
    @Persisted var course: Double = 0.0
    @Persisted var speed: Double = 0.0
    @Persisted var timestamp: Date = Date.now
    @Persisted var track: Track?
}
