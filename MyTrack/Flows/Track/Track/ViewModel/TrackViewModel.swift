//
//  TrackViewModel.swift
//  MyTrack
//
//  Created by Denis Dmitriev on 06.03.2023.
//

import UIKit
import GoogleMaps
import RxSwift
import RxCocoa

class TrackViewModel {
    
    var viewController: TrackViewController?
    var realmService: RealmService?
    var onUser: (() -> Void)?
    var onTracks: (() -> Void)?
    
    var isTracking: Bool? {
        try? Session.shared.isTracking.value()
    }
    
    var startMarker: GMSMarker?
    var finishMarker: GMSMarker?
    
    var usselesExampleVariable: String = "" //will remove
    
    let locationManager = LocationManager.instance
    
    var route: GMSPolyline? //линия пути
    var routePath: GMSMutablePath? //пройденный путь/маршрут
    
    var trackManager: TrackManager?
    var zoom: Float = 15
    var strokeWidth: CGFloat = 10
    
    var uiViewDefaultConstraint: CGFloat = 0
    var uiViewDownOffset: CGFloat = 0
    var uiViewUp: CGPoint = CGPoint()
    var uiViewDown: CGPoint = CGPoint()
    
    let disposeBag = DisposeBag()
    
    func getUserImage() -> UIImage? {
        guard
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("user", conformingTo: .image)
        else { return nil }
        
        do {
            let data = try Data(contentsOf: path)
            let image = UIImage(data: data)
            return image
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func alertTracking() -> UIAlertController {
        let alertController = UIAlertController(
            title: "You are in tracking",
            message: "Before opening you must finish the current.",
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: "Ok", style: .default)
        alertController.addAction(action)
        
        return alertController
    }
    
    func bindButton() {
        Session.shared.isTracking
            .bind { [weak self] isTracking in
                let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30, weight: .heavy)]
                let title = (isTracking ?? false) ? "Finish" : "Start"
                let attributedText = AttributedString(NSLocalizedString(title, comment: "Some buttons"), attributes: AttributeContainer(attributes))
                self?.viewController?.trackActionButton.configuration?.attributedTitle = attributedText
                self?.viewController?.trackActionButton.tintColor = (isTracking ?? false) ? .systemPurple : .systemBlue
            }
            .disposed(by: disposeBag)
    }
    
    func bindLocation() {
        locationManager.location
            .asObservable()
            .bind { [weak self] location in
                guard let location = location else { return }
                do {
                    let isTracking = try Session.shared.isTracking.value()
                    
                    switch isTracking {
                    case true:
                        if self?.trackManager == nil {
                            self?.trackManager = TrackManager(startTime: Date.now)
                            self?.startMarker = self?.marker(on: location.coordinate)
                        }
                        self?.viewController?.routeUpdate(location: location)
                        self?.trackManager?.locations.append(location)
                        self?.trackInfo()
                        self?.viewController?.cameraTo(location)
                        
                    case false:
                        self?.locationManager.locationManager.stopUpdatingLocation()
                        if self?.trackManager?.finishTime == nil {
                            self?.trackManager?.finishTime = Date.now
                            self?.finishMarker = self?.marker(on: location.coordinate)
                            self?.viewController?.routeUpdate(location: location)
                            self?.trackInfo()
                            self?.saveTrack(from: self?.trackManager)
                        }
                        
                    default:
                        self?.locationManager.locationManager.stopUpdatingLocation()
                        self?.viewController?.cameraTo(location)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
            .disposed(by: disposeBag)
    }
    
    func reloadTrack(track: Track) {
        trackManager = TrackManager(track: track)
        configureTrack()
    }
    
    func removeTrack() {
        trackManager = nil
    }
    
    func duration() -> String? {
        trackManager?.stringDuration()
    }
    
    //MARK: - Realm Data
    
    func saveTrack(from trackManager: TrackManager?) {
        if realmService == nil {
            realmService = RealmService()
            realmService?.getPathForDataFile() //to console
        }
        
        guard
            let trackManager = trackManager,
            let startTime = trackManager.startTime,
            let finishTime = trackManager.finishTime
        else { return }
        
        realmService?.addTrack(startTime: startTime, finishTime: finishTime, distance: trackManager.distance, locations: trackManager.locations.locations)
    }
    
    func startTracking() {
        do {
            let isTracking = try Session.shared.isTracking.value()
            
            switch isTracking {
            case true:
                Session.shared.isTracking.onNext(false)
                locationManager.locationManager.stopMonitoringSignificantLocationChanges()
            default:
                viewController?.removeTrackFromMap()
                
                Session.shared.isTracking.onNext(true)
                locationManager.locationManager.startMonitoringSignificantLocationChanges()
                viewController?.stopwatch()
                viewController?.createRoute()
                locationManager.locationManager.startUpdatingLocation()
                
                UIView.animate(withDuration: 0.3) {
                    self.viewController?.uiView.center = self.uiViewDown
                }
                if viewController?.uiViewBottomConstraint.constant == uiViewDefaultConstraint {
                    viewController?.uiViewBottomConstraint.constant -= uiViewDownOffset
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func loadTrack() {
        guard
            let startLocation = trackManager?.locations.first,
            let finishLoaction = trackManager?.locations.last
        else { return }
        
        startMarker = marker(on: startLocation.coordinate)
        finishMarker = marker(on: finishLoaction.coordinate)
        
        viewController?.createRoute(for: trackManager?.locations)
        
        trackInfo()
        
        viewController?.cameraFitTrack()
    }
    
    // MARK: - Private functions
    
    private func configureTrack() {
        guard
            let startLocation = trackManager?.locations.first,
            let finishLoaction = trackManager?.locations.last
        else { return }
        
        startMarker = marker(on: startLocation.coordinate)
        finishMarker = marker(on: finishLoaction.coordinate)
        
        viewController?.createRoute(for: trackManager?.locations)
        
        trackInfo()
        
        self.viewController?.cameraFitTrack()
    }
    
    private func trackInfo() {
        guard let trackManager = trackManager else { return }
        
        let isTracking = try? Session.shared.isTracking.value()
        
        if isTracking != true {
            viewController?.timeLabel.text = "\(trackManager.stringDuration())" //00:00
        }
        viewController?.trackLabel.text = "\(trackManager.stringDistance())" //m
        viewController?.speedLabel.text = "\(trackManager.stringSpeed())" //m/s
    }
    
    private func marker(on coordinate: CLLocationCoordinate2D) -> GMSMarker {
        let marker = GMSMarker(position: coordinate)
        marker.appearAnimation = .pop
        marker.map = viewController?.mapView
        return marker
    }
}
