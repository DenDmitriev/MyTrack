//
//  CLLocationExtension.swift
//  MyTrack
//
//  Created by Denis Dmitriev on 16.02.2023.
//

import Foundation
import GoogleMaps

extension [CLLocation] {
    var locations: [Location] {
        return self.map { CLlocation in
            let location = Location()
            location.longitude = CLlocation.coordinate.longitude
            location.latitude = CLlocation.coordinate.latitude
            location.altitude = CLlocation.altitude
            location.horizontalAccuracy = CLlocation.horizontalAccuracy
            location.verticalAccuracy = CLlocation.verticalAccuracy
            location.course = CLlocation.course
            location.speed = CLlocation.speed
            location.timestamp = CLlocation.timestamp
            
            return location
        }
    }
}

extension [Location] {
    var clLocations: [CLLocation] {
        return self.map { location in
            CLLocation(
                coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude),
                altitude: location.altitude,
                horizontalAccuracy: location.horizontalAccuracy,
                verticalAccuracy: location.verticalAccuracy,
                course: location.course,
                speed: location.speed,
                timestamp: location.timestamp
            )
        }.sorted { $0.timestamp < $1.timestamp }
    }
}
