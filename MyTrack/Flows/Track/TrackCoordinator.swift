//
//  TrackCoordinator.swift
//  MyTrack
//
//  Created by Denis Dmitriev on 09.02.2023.
//

import UIKit

class TrackCoordinator: Coordinator {
    var rootController: UINavigationController?
    
    var onFinishFlow: (() -> Void)?
    
    func start(with track: Track?) {
        showTrackModule()
    }
    
    override func start() {
        showTrackModule()
    }
    
    private func showTrackModule() {
//        guard let controller = UIStoryboard(name: "Track", bundle: nil).instantiateViewController(withIdentifier: "TrackViewController") as? TrackViewController else { return }
        let controller = TrackBuilder.build()
        controller.viewModel?.onUser = { [weak self] in
            self?.showUserModule()
        }
        controller.viewModel?.onTracks = { [weak self] in
            self?.showTracksModule()
        }
        let rootController = UINavigationController(rootViewController: controller)
        setAsRoot(rootController)
        self.rootController = rootController
    }
    
    private func showUserModule() {
        guard let controller = UIStoryboard(name: "User", bundle: nil).instantiateViewController(withIdentifier: "UserViewController") as? UserViewController else { return }
        controller.onLogout = { [weak self] in
            UserDefaults.standard.set(false, forKey: "isLogin")
            self?.onFinishFlow?()
        }
        controller.toTrack = { [weak self] stringValue in
            self?.rootController?.popViewController(animated: true)
        }
        controller.navigationItem.title = "Profile"
        rootController?.pushViewController(controller, animated: true)
    }
    
    private func showTracksModule() {
        guard let controller = UIStoryboard(name: "Track", bundle: nil).instantiateViewController(withIdentifier: "TrackCollectionViewController") as? TrackCollectionViewController else { return }
        
        controller.toTrack = { [weak self] track in
            if let trackController = self?.rootController?.viewControllers.first as? TrackViewController,
                let track = track {
                trackController.reloadTrack(track: track)
            }
            self?.rootController?.popViewController(animated: true)
        }
        controller.navigationItem.title = NSLocalizedString("Your Tracks", comment: "title")
        rootController?.pushViewController(controller, animated: true)
    }
}
