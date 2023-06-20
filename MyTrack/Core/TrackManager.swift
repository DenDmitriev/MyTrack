//
//  TrackManager.swift
//  MyTrack
//
//  Created by Denis Dmitriev on 31.01.2023.
//

import Foundation
import GoogleMaps

class TrackManager {
    
    var startTime: Date?
    var finishTime: Date?
    
    var distance: Double = 0
    
    var locations: [CLLocation] = [] {
        willSet {
            guard
                newValue.count > 1,
                let newLocation = newValue.last,
                let lastIndex = newValue.lastIndex(of: newLocation)
            else { return }
            
            let lastLoaction = newValue[lastIndex - 1]
            let distance = newLocation.distance(from: lastLoaction)
            
            self.distance += distance
        }
    }
    
    init(startTime: Date? = nil, finishTime: Date? = nil, locations: [CLLocation] = [], distance: Double = 0) {
        self.startTime = startTime
        self.finishTime = finishTime
        self.distance = distance
        self.locations = locations
    }
    
    init(track: Track) {
        self.startTime = track.startTime
        self.finishTime = track.finishTime
        self.locations = track.locations.sorted { $0.timestamp < $1.timestamp }.clLocations
        self.distance = track.distance
    }
    
    private func description(location: CLLocationCoordinate2D?, date: Date) -> String {
        guard let location = location else { return "" }
        
        let latitude = location.latitude
        let longitude = location.longitude
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        
        let description: String = formatter.string(from: date) + "\n\(latitude)" + ", \(longitude)"
        return description
    }
    
    func stringSpeed() -> String {
        var speed: Double {
            if finishTime == nil {
                return locations.last?.speed ?? 0.0
            } else {
                var total = 0.0
                locations.forEach { total += $0.speed }
                let average = total / Double(locations.count)
                return average
            }
        }
        let roundedSpeed = (speed * 10).rounded() / 10
        
        //return "\(roundedSpeed)" + NSLocalizedString("m/s", comment: "")
        //return NSLocalizedString("m/s", comment: "Unit format")
        let stringSpeed = String(roundedSpeed) + " " + NSLocalizedString("m/s", comment: "Unit format")
        return stringSpeed
    }
    
    func stringDuration() -> String {
        guard
            let startTime = startTime
        else { return "" }
        
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = (finishTime ?? Date.now).timeIntervalSince(startTime) >= 3600 ? [.hour, .minute, .second] : [.minute, .second]
        let duration = formatter.string(from: startTime, to: finishTime ?? Date.now) ?? ""
        
        return duration
        
    }
    
    func stringDistance() -> String {
        let roundedDistance = distance.rounded()
        let lenghtFormatter = LengthFormatter()
        lenghtFormatter.unitStyle = .short
        var unit: LengthFormatter.Unit {
            switch roundedDistance {
            case 1000.0...:
                return .kilometer
            default:
                return .meter
            }
        }
        return lenghtFormatter.string(fromValue: roundedDistance, unit: unit)
    }
    
}
