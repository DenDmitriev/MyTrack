//
//  TrackViewController.swift
//  MyTrack
//
//  Created by Denis Dmitriev on 30.01.2023.
//

import UIKit
import GoogleMaps
import RealmSwift
import RxSwift
import RxCocoa

class TrackViewController: UIViewController {
    
    var viewModel: TrackViewModel?
    var zoom: Float = 15
    /// Линия пути
    var route: GMSPolyline?
    /// Пройденный путь/маршрут
    var routePath: GMSMutablePath?
    /// Толщина линии пути
    var strokeWidth: CGFloat = 10
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var uiView: UIView!
    @IBOutlet weak var trackLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var trackActionButton: UIButton!
    @IBOutlet weak var uiStackView: UIStackView!
    @IBOutlet weak var uiViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var userImageView: UIImageView!
    private var uiViewDefaultConstraint: CGFloat = 0
    private var uiViewDownOffset: CGFloat = 0
    private var uiViewUp: CGPoint = CGPoint()
    private var uiViewDown: CGPoint = CGPoint()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureMap()
        configureLocationManager()
        configureTrack()
    }
    
    //MARK: - Configure
    
    private func configureUI() {
        
        //View UI
        uiView.layer.cornerRadius = 16
        let color = uiView.backgroundColor
        uiView.backgroundColor = color?.withAlphaComponent(0.9)
        uiView.layer.shadowColor = UIColor.black.cgColor
        uiView.layer.shadowRadius = 4
        uiView.layer.shadowOpacity = 0.2
        
        let countViews = CGFloat(uiStackView.arrangedSubviews.count)
        let countVisibaleViews: CGFloat = 2
        let heightView = uiStackView.frame.height
        let spacing = uiStackView.spacing
        let safeArea: CGFloat = 16
        
        uiViewDownOffset = (countViews - countVisibaleViews) * (((heightView - spacing * (countViews - 1)) / countViews) + uiViewBottomConstraint.constant + safeArea)
        uiViewUp = uiView.center
        uiViewDown = CGPoint(x: uiView.center.x, y: uiView.center.y + uiViewDownOffset)
        uiViewDefaultConstraint = uiViewBottomConstraint.constant
        
        //Labels
        let labels = [trackLabel, timeLabel, speedLabel]
        labels.forEach { label in
            label?.adjustsFontSizeToFitWidth = true
        }
        
        //Action button
        viewModel?.bindButton()
        
        //User buttom
        userImageView.layer.cornerRadius = userImageView.frame.height / 2
        userImageView.layer.masksToBounds = true
        userImageView.layer.borderColor = UIColor.gray.cgColor
        userImageView.layer.borderWidth = 2
    }
    
    //MARK: - Actions
    
    func reloadTrack(track: Track) {
        viewModel?.reloadTrack(track: track)
    }
    
    @IBAction func didTapUserAction(_ sender: UITapGestureRecognizer) {
        do {
            let isTracking = try Session.shared.isTracking.value()
            if isTracking ?? false {
                alertIsTracking {
                    print(#function)
                }
            } else {
                viewModel?.onUser?()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func startTrackingAction(_ sender: UIButton) {
        viewModel?.startTracking()
    }
    
    @IBAction func tracksDidTaped(_ sender: UIButton) {
        viewModel?.onTracks?()
    }
    
    @IBAction func uiViewPanGesture(_ sender: UIPanGestureRecognizer) {
        let velocity = sender.velocity(in: uiView)
        
        if sender.state == .ended {
            if velocity.y > 0 && uiViewBottomConstraint.constant == uiViewDefaultConstraint {
                UIView.animate(withDuration: 0.3) {
                    self.uiView.center = self.uiViewDown
                }
                uiViewBottomConstraint.constant -= uiViewDownOffset
            } else if velocity.y < 0 && uiViewBottomConstraint.constant == (uiViewDefaultConstraint - uiViewDownOffset) {
                UIView.animate(withDuration: 0.3) {
                    self.uiView.center = self.uiViewUp
                }
                uiViewBottomConstraint.constant += uiViewDownOffset
            }
        }
    }
    
    // MARK: - UI Functions
    
    func downSegmentControl() {
        UIView.animate(withDuration: 0.3) {
            self.uiView.center = self.uiViewDown
        }
        if uiViewBottomConstraint.constant == uiViewDefaultConstraint {
            uiViewBottomConstraint.constant -= uiViewDownOffset
        }
    }
    
    func stopwatch() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            let isTracking = self.viewModel?.isTracking
            if isTracking != true {
                timer.invalidate()
            }
            self.timeLabel.text = self.viewModel?.duration()
        }
    }
    
    //MARK: - Maps functions
    
    func removeTrackFromMap() {
        viewModel?.removeTrack()
        mapView.clear()
    }
    
    func clearMapView() {
        mapView.clear()
    }
    
    func trackInfo(isTracking: Bool, duration: String, speed: String, distance: String) {
        timeLabel.text = duration
        trackLabel.text = distance
        speedLabel.text = speed
    }
    
    func cameraTo(_ location: CLLocation) {
        let postion = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: self.zoom)
        self.mapView.animate(to: postion)
    }
    
    func createRoute(for locations: [CLLocation]? = nil) {
        route = GMSPolyline()
        let spans: [GMSStyleSpan] = []
        route?.spans = spans
        routePath = GMSMutablePath()
        route?.strokeWidth = strokeWidth
        route?.map = mapView
        
        locations?.forEach { location in
            routePath?.add(location.coordinate)
            let span = GMSStyleSpan.getColor(by: location.speed)
            route?.spans?.append(span)
        }
        route?.path = routePath
    }
    
    func routeUpdate(location: CLLocation) {
        routePath?.add(location.coordinate)
        route?.path = routePath
        //Polyline color
        let span = GMSStyleSpan.getColor(by: location.speed)
        route?.spans?.append(span)
    }
    
    func cameraFitTrack() {
        guard let path = route?.path else { return }
        let bounds = GMSCoordinateBounds(path: path)
        self.mapView.animate(with: .fit(bounds, with: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)))
    }
    
    private func configureMap() {
        mapView.isMyLocationEnabled = true
        let camera = GMSCameraPosition.camera(withTarget: mapView.myLocation?.coordinate ?? CLLocationCoordinate2D(latitude: -180, longitude: -180), zoom: zoom)
        mapView.camera = camera
        mapView.padding = UIEdgeInsets(top: 64, left: 32, bottom: (uiView.frame.height + 32), right: 32)
        mapView.delegate = self
        mapView.settings.compassButton = true
        mapView.settings.myLocationButton = true
    }
    
    private func configureLocationManager() {
        viewModel?.bindLocation()
    }
    
    private func configureTrack() {
        viewModel?.loadTrack()
        self.cameraFitTrack()
    }
    
    // MARK: - Private functions
    
    private func alertIsTracking(operation: @escaping (() -> ())) {
        let alertController = UIAlertController(
            title: "You are in tracking",
            message: "Before opening you must finish the current.",
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: "Ok", style: .default) { _ in
            operation()
        }
        alertController.addAction(action)
        
        self.present(alertController, animated: true)
    }
    
}

extension TrackViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        zoom = mapView.camera.zoom
    }
}
