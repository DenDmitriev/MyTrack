//
//  Coordinator.swift
//  MyTrack
//
//  Created by Denis Dmitriev on 09.02.2023.
//

import UIKit

class Coordinator {
    
    var parent: Coordinator?
    var child: [Coordinator] = []
    
    func start() {}
    
    func addDependency(_ coordinator: Coordinator) {
        for element in child where element === coordinator {
            return
        }
        child.append(coordinator)
    }
    
    func removeDependency(_ coordinator: Coordinator?) {
        guard
            child.isEmpty == false,
            let coordinator = coordinator
        else { return }
        
        for (index, element) in child.reversed().enumerated() where element === coordinator {
            child.remove(at: index)
            break
        }
    }
    
    func setAsRoot(_ controller: UIViewController) {
        if #available(iOS 13, *) {
            let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
            sceneDelegate?.window?.rootViewController = controller
        } else {
            UIApplication.shared.keyWindow?.rootViewController = controller
        }
    }
}
