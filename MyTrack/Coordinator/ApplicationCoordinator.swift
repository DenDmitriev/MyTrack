//
//  ApplicationCoordinator.swift
//  MyTrack
//
//  Created by Denis Dmitriev on 09.02.2023.
//

import Foundation

class ApplicationCoordinator: Coordinator {
    
    override func start() {
        if UserDefaults.standard.bool(forKey: "isLogin") {
            toTrack()
        } else {
            toAuth()
        }
    }
    
    private func toTrack() {
        let coordinator = TrackCoordinator()
        
        coordinator.onFinishFlow = { [weak self, weak coordinator] in
            self?.removeDependency(coordinator)
            self?.start()
        }
        
        addDependency(coordinator)
        coordinator.start()
    }
    
    private func toAuth() {
        let coordinator = AuthCoordinator()
        
        coordinator.onFinishFlow = { [weak self, weak coordinator] in
            self?.removeDependency(coordinator)
            self?.start()
        }
        
        addDependency(coordinator)
        coordinator.start()
    }
}
