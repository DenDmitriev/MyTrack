//
//  TrackCollectionViewCell.swift
//  MyTrack
//
//  Created by Denis Dmitriev on 02.02.2023.
//

import UIKit
import GoogleMaps

class TrackCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var adressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configure()
    }
    
    private func configureMap(for track: Track) {
        let route = GMSPolyline()
        route.strokeWidth = 5
        route.spans = []
        let routePath = GMSMutablePath()
        route.map = mapView
        track.locations.sorted { $0.timestamp < $1.timestamp }.forEach { location in
            routePath.add(CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
            route.spans?.append(GMSStyleSpan.getColor(by: location.speed))
        }
        route.path = routePath
        route.map = mapView
        
        mapView.bounds = self.bounds
        let bounds = GMSCoordinateBounds(path: routePath)
        //self.mapView.cameraTargetBounds = bounds //ограничить границы
        self.mapView.settings.scrollGestures = false
        self.mapView.settings.tiltGestures = false
        self.mapView.settings.zoomGestures = false
        self.mapView.settings.rotateGestures = false
        
        geoFetch(for: track.locations.first)
        
        self.mapView.moveCamera(.fit(bounds, with: UIEdgeInsets(top: 16, left: (mapView.bounds.width / 2), bottom: 16, right: 16)))
    }
    
    private func configure() {
        self.layer.cornerRadius = 8
        
        let labels = [timeLabel, distanceLabel, dateLabel]
        labels.forEach { label in
            label?.adjustsFontSizeToFitWidth = true
        }
        
        mapView.isIndoorEnabled = false
        mapView.accessibilityElementsHidden = true
        mapView.isBuildingsEnabled = false
        
        bgView.backgroundColor = bgView.backgroundColor?.withAlphaComponent(0.5)
    }
    
    private func geoFetch(for location: Location?) {
        guard
            let latitude = location?.latitude,
            let longitude = location?.longitude
        else { return }
        let locationCL = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let geo = GMSGeocoder()
        geo.reverseGeocodeCoordinate(locationCL) { response, error in
            self.adressLabel.text = response?.firstResult()?.locality
        }
    }
    
    func set(for track: Track) {
        
        configureMap(for: track)
        
        let formatter = DateComponentsFormatter()
        switch track.finishTime.timeIntervalSince(track.startTime) {
        case ...60:
            formatter.allowedUnits = [.second]
        case 61...3600:
            formatter.allowedUnits = [.minute, .second]
        default:
            formatter.allowedUnits = [.hour, .minute, .second]
        }
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = [.default]
        let duration = formatter.string(from: track.startTime, to: track.finishTime)
        
        let roudedDistance = track.distance.rounded()
        let lenghtFormatter = LengthFormatter()
        lenghtFormatter.unitStyle = .short
        var lenghtUnit: LengthFormatter.Unit = .meter
        switch track.distance {
        case 1000.0...:
            lenghtUnit = .kilometer
        default:
            lenghtUnit = .meter
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        distanceLabel.text = lenghtFormatter.string(fromValue: roudedDistance, unit: lenghtUnit)
        timeLabel.text = duration
        dateLabel.text = dateFormatter.string(from: track.startTime)
    }

}
