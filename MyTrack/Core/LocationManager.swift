//
//  LocationManager.swift
//  MyTrack
//
//  Created by Denis Dmitriev on 16.02.2023.
//

import Foundation
import CoreLocation
import RxSwift
import GoogleMaps

class LocationManager: NSObject {
    static let instance = LocationManager()
    
    let locationManager = CLLocationManager()
    let disposeBag = DisposeBag()
    
    let location: BehaviorSubject<CLLocation?> = .init(value: nil)
    
    private override init() {
        super.init()
        configureLocationManager()
    }
    
    private func configureLocationManager() {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        locationManager.allowsBackgroundLocationUpdates = true
        Session.shared.isTracking
            .bind { [weak locationManager] isTracking in
                locationManager?.pausesLocationUpdatesAutomatically = !(isTracking ?? false)
            }
            .disposed(by: disposeBag)
        locationManager.requestAlwaysAuthorization()
        
        locationManager.requestLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.location.onNext(locations.last)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}


